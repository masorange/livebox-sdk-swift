import Foundation

/// The entry point to interact with a Livebox router.
///
/// `LiveboxAPI` provides high-level methods for common router operations. Each method relies on a feature
/// published in the router's capabilities, so fetch them first with ``login(username:password:completion:)``
/// or ``getCapabilities(completion:)``. Otherwise, requests fail with ``LiveboxError/featureNotFound(_:)``.
///
/// ## Authentication
///
/// The Livebox API does not maintain sessions. Instead, credentials are sent with each request using
/// HTTP Basic Authentication. Since the router has no login endpoint, the capabilities request is used
/// to validate credentials:
///
/// - ``login(username:password:completion:)`` sets the credentials and fetches the capabilities to check them.
///   If the request fails, the previous credentials are restored.
/// - ``getCapabilities(completion:)`` fetches the capabilities with the current credentials, without changing them.
/// - ``updateCredentials(username:password:)`` sets the credentials without checking them.
///
/// ## Identifiers
///
/// - `wlanIfc` is the identifier of a Wi-Fi interface, such as ``Wifi/id`` or ``WlanInterface/id``.
/// - `wlanAp` is the identifier of an access point: ``WlanInterface/ShortAccessPoint/idx``. Depending on the
///   manufacturer and the network, routers use either an index or the BSSID without colons.
/// - `mac` is the MAC address of a device, such as ``DeviceInfo/physAddress``.
///
/// Colons are removed from `wlanAp` and `mac` before sending the request, so both `AA:BB:CC:DD:EE:FF` and
/// `AABBCCDDEEFF` are accepted.
///
/// ## Schedules
///
/// A ``Schedule`` is a 1-hour slot during which devices have no access to the network.
/// Parental control schedules apply to a single device, and Wi-Fi schedules apply to the whole router.
public class LiveboxAPI {
    /// The client used to make API requests.
    private var client: LiveboxClient

    /// Whether the capabilities have been fetched.
    private var capabilitiesFetched = false

    /// Whether credentials are set.
    ///
    /// It's `true` after a successful ``login(username:password:completion:)``, or when credentials are provided
    /// at creation or through ``updateCredentials(username:password:)``. In the last two cases, the credentials
    /// haven't been validated.
    private(set) public var isAuthenticated = false

    /// The base URL of the router API.
    public var baseURL: URL {
        return client.configuration.baseURL
    }

    /// The current username, if any.
    public var currentUsername: String? {
        return client.configuration.username
    }

    /// An empty struct used for requests that don't need a body.
    struct EmptyBody: Encodable {}

    /// Creates a new Livebox service with the specified client.
    ///
    /// If the client already has credentials, ``isAuthenticated`` is `true`.
    /// - Parameter client: The client to use for making API requests.
    public init(client: LiveboxClient) {
        self.client = client
        // If client already has credentials, assume we're authenticated
        self.isAuthenticated = client.configuration.username != nil && client.configuration.password != nil
    }

    /// Creates a new Livebox service with a base URL (without authentication).
    /// Use ``login(username:password:completion:)`` to authenticate after creation.
    /// - Parameter baseURLString: The base URL string for the router API.
    /// - Throws: An error if the baseURLString is not a valid URL.
    public convenience init(baseURLString: String) throws {
        let client = try LiveboxClientFactory.createClient(baseURLString: baseURLString, username: nil, password: nil)
        self.init(client: client)
    }

    /// Creates a new Livebox service with a base URL (without authentication).
    /// Use ``login(username:password:completion:)`` to authenticate after creation.
    /// - Parameter baseURL: The base URL for the router API.
    public convenience init(baseURL: URL) {
        let client = LiveboxClientFactory.createClient(baseURL: baseURL, username: nil, password: nil)
        self.init(client: client)
    }

    /// Creates a new authenticated Livebox service with a base URL and credentials.
    /// This is a convenience initializer that creates the service and sets credentials in one step.
    /// - Parameters:
    ///   - baseURLString: The base URL string for the router API.
    ///   - username: Username for authentication (default: "UsrAdmin")
    ///   - password: Password for authentication
    /// - Throws: An error if the baseURLString is not a valid URL.
    public convenience init(baseURLString: String, username: String = "UsrAdmin", password: String) throws {
        let client = try LiveboxClientFactory.createClient(baseURLString: baseURLString, username: username, password: password)
        self.init(client: client)
    }

    /// Creates a new authenticated Livebox service with a base URL and credentials.
    /// This is a convenience initializer that creates the service and sets credentials in one step.
    /// - Parameters:
    ///   - baseURL: The base URL for the router API.
    ///   - username: Username for authentication (default: "UsrAdmin")
    ///   - password: Password for authentication
    public convenience init(baseURL: URL, username: String = "UsrAdmin", password: String) {
        let client = LiveboxClientFactory.createClient(baseURL: baseURL, username: username, password: password)
        self.init(client: client)
    }

    /// Authenticates with the router using the provided credentials.
    ///
    /// This method sets the credentials and fetches the capabilities to validate them.
    /// If the request fails, the previous credentials are restored.
    ///
    /// It also checks that the router is compatible: incompatible routers don't publish any feature.
    /// - Parameters:
    ///   - username: Username for authentication (default: "UsrAdmin")
    ///   - password: Password for authentication
    ///   - completion: A callback to invoke when authentication completes. On success, the value is `true`
    ///     if the router published at least one feature.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func login(
        username: String = "UsrAdmin",
        password: String,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) -> URLSessionDataTask? {
        // Store current credentials in case we need to restore them
        let previousUsername = client.configuration.username
        let previousPassword = client.configuration.password

        // Update credentials for authentication test
        do {
            try client.updateCredentials(username: username, password: password)
        } catch {
            completion(.failure(error))
            return nil
        }

        // Test authentication by fetching capabilities
        return client.getCapabilities { [weak self] result in
            switch result {
            case .success(let capabilities):
                // Authentication successful
                self?.isAuthenticated = true
                self?.capabilitiesFetched = true
                completion(.success(!capabilities.features.isEmpty))
            case .failure(let error):
                // Authentication failed, restore previous credentials
                do {
                    try self?.client.updateCredentials(username: previousUsername, password: previousPassword)
                } catch {
                    // If we can't restore credentials, at least complete with the original error
                }
                completion(.failure(error))
            }
        }
    }

    /// Logs out by clearing the credentials.
    ///
    /// This method doesn't make any network request.
    public func logout() {
        try? client.updateCredentials(username: nil, password: nil)
        isAuthenticated = false
        capabilitiesFetched = false
    }

    /// Updates the authentication credentials without validating them.
    ///
    /// Use ``login(username:password:completion:)`` to validate the credentials.
    /// - Parameters:
    ///   - username: New username for authentication
    ///   - password: New password for authentication
    /// - Throws: An error if the credentials cannot be updated
    public func updateCredentials(username: String?, password: String?) throws(LiveboxError) {
        try client.updateCredentials(username: username, password: password)
        isAuthenticated = (username != nil && password != nil)
        // Don't reset capabilitiesFetched as they may still be valid
    }

    /// Updates the base URL for the router API.
    /// - Parameters:
    ///   - baseURL: The new base URL for the router API
    ///   - clearCapabilities: Whether to clear cached capabilities (default: false)
    public func updateBaseURL(_ baseURL: URL, clearCapabilities: Bool = false) {
        client.updateBaseURL(baseURL, clearCache: clearCapabilities)
        // Reset capabilities flag if clearing capabilities
        if clearCapabilities {
            capabilitiesFetched = false
        }
    }

    /// Updates the base URL for the router API.
    /// - Parameters:
    ///   - baseURLString: The new base URL string for the router API
    ///   - clearCapabilities: Whether to clear cached capabilities (default: false)
    /// - Throws: An error if the baseURLString is not a valid URL
    public func updateBaseURL(_ baseURLString: String, clearCapabilities: Bool = false) throws(LiveboxError) {
        guard let url = URL(string: baseURLString) else {
            throw LiveboxError.invalidURL(baseURLString)
        }

        updateBaseURL(url, clearCapabilities: clearCapabilities)
    }

    /// Fetches the capabilities of the router.
    ///
    /// The capabilities are cached and used to build the requests of the other methods.
    /// - Parameter completion: A callback to invoke when the operation completes, with either the capabilities or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getCapabilities(completion: @escaping (Result<Capabilities, LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.getCapabilities { [weak self] result in
            if case .success = result {
                self?.capabilitiesFetched = true
            }
            completion(result)
        }
    }

    /// Gets the router's general information.
    /// - Parameter completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getGeneralInfo(completion: @escaping (Result<GeneralInfo, LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.requestFeature(id: .generalInfo, method: .get, completion: completion)
    }

    /// Reboots the router.
    /// - Parameter completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func reboot(completion: @escaping (Result<Void, LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.invokeFeature(id: .reboot, body: nil as EmptyBody?, completion: completion)
    }

    /// Gets the router's Wi-Fi interfaces.
    /// - Parameter completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getWifiInterfaces(completion: @escaping (Result<[Wifi], LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.requestFeature(id: .wifi, method: .get, completion: completion)
    }

    /// Gets a specific router's Wi-Fi interface.
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getWlanInterface(wlanIfc: String, completion: @escaping (Result<WlanInterface, LiveboxError>) -> Void)
        -> URLSessionDataTask?
    {
        client.requestFeature(id: .wlanInterface, pathVariables: ["wlan_ifc": wlanIfc], method: .get, completion: completion)
    }

    /// Gets the details of a specific Wi-Fi access point.
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getAccessPoint(
        wlanIfc: String, wlanAp: String, completion: @escaping (Result<AccessPoint, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanAccessPoint,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .get,
            completion: completion
        )
    }

    /// Updates the details of a specific Wi-Fi access point.
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - accessPoint: The new details of the access point.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func updateAccessPoint(
        wlanIfc: String, wlanAp: String, accessPoint: AccessPoint,
        completion: @escaping (Result<AccessPoint, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanAccessPoint,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .put,
            body: accessPoint,
            completion: completion
        )
    }

    /// Retrieves the list of devices known by the router.
    ///
    /// Check ``DeviceInfo/active`` to know whether a device is currently connected.
    /// - Parameter completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getConnectedDevices(completion: @escaping (Result<[DeviceInfo], LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.requestFeature(
            id: .connectedDevices,
            method: .get,
            completion: completion
        )
    }

    /// Retrieves the details of a specific device.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getDeviceDetail(mac: String, completion: @escaping (Result<DeviceDetail, LiveboxError>) -> Void) -> URLSessionDataTask? {
        client.requestFeature(
            id: .connectedDevicesMac,
            pathVariables: ["mac": mac.removingColons],
            method: .get,
            completion: completion
        )
    }

    /// Sets the alias of a specific device.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - alias: The new alias for the device.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func setDeviceAlias(mac: String, alias: String, completion: @escaping (Result<DeviceDetail, LiveboxError>) -> Void)
        -> URLSessionDataTask?
    {
        client.requestFeature(
            id: .connectedDevicesMac,
            pathVariables: ["mac": mac.removingColons],
            method: .put,
            body: ["alias": alias],
            completion: completion
        )
    }

    /// Gets the parental control schedules of a specific device.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getDeviceSchedules(mac: String, completion: @escaping (Result<Schedules, LiveboxError>) -> Void)
        -> URLSessionDataTask?
    {
        client.requestFeature(
            id: .pcDevicesMacSchedules,
            pathVariables: ["mac": mac.removingColons],
            method: .get,
            completion: completion
        )
    }

    /// Adds parental control schedules to a specific device.
    ///
    /// This method first enables the schedules of the device with
    /// ``changeDeviceScheduleStatus(mac:status:completion:)``, and then adds the schedules.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - schedules: The new schedules for the device.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the first request (the status change).
    @discardableResult
    public func addDeviceSchedules(
        mac: String,
        schedules: Schedules,
        completion: @escaping (Result<Schedules, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        changeDeviceScheduleStatus(
            mac: mac,
            status: .init(mac: mac, status: .enabled)
        ) { [weak self] result in
            switch result {
            case .success:
                _ = self?.client.requestFeature(
                    id: .pcDevicesMacSchedules,
                    pathVariables: ["mac": mac.removingColons],
                    method: .post,
                    body: schedules,
                    completion: completion
                )

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Enables or disables the parental control schedules of a device.
    ///
    /// ``addDeviceSchedules(mac:schedules:completion:)`` calls this method to enable the schedules before adding them.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - status: The status to set.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func changeDeviceScheduleStatus(
        mac: String,
        status: DeviceScheduleStatus,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .pcDevicesMac,
            pathVariables: ["mac": mac.removingColons],
            method: .put,
            body: status
        ) { (result: Result<EmptyResponse, LiveboxError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Deletes parental control schedules of a specific device.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - schedules: The schedules to delete.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func deleteDeviceSchedules(mac: String, schedules: Schedules, completion: @escaping (Result<Schedules, LiveboxError>) -> Void)
        -> URLSessionDataTask?
    {
        client.requestFeature(
            id: .pcDevicesMacSchedules,
            pathVariables: ["mac": mac.removingColons],
            method: .delete,
            body: schedules,
            completion: completion
        )
    }

    /// Retrieves the Wi-Fi schedules of the router.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getWlanSchedules(
        wlanIfc: String,
        wlanAp: String,
        completion: @escaping (Result<Schedules, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanSchedule,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .get,
            completion: completion
        )
    }

    /// Adds Wi-Fi schedules to the router.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - schedules: The schedules to add.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func addWlanSchedules(
        wlanIfc: String,
        wlanAp: String,
        schedules: Schedules,
        completion: @escaping (Result<Schedules, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanSchedule,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .post,
            body: schedules,
            completion: completion
        )
    }

    /// Deletes Wi-Fi schedules from the router.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - schedules: The schedules to delete.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func deleteWlanSchedules(
        wlanIfc: String,
        wlanAp: String,
        schedules: Schedules,
        completion: @escaping (Result<Schedules, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanSchedule,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .delete,
            body: schedules,
            completion: completion
        )
    }

    /// Retrieves whether the router's Wi-Fi schedules are enabled.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func getWlanScheduleStatus(
        wlanIfc: String,
        wlanAp: String,
        completion: @escaping (Result<WlanScheduleStatus, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanScheduleEnable,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .get,
            completion: completion
        )
    }

    /// Enables or disables the router's Wi-Fi schedules.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The identifier of the Wi-Fi interface.
    ///   - wlanAp: The identifier of the access point.
    ///   - status: The status to set.
    ///   - completion: A callback to invoke with the result.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or `nil` if the request couldn't be started.
    @discardableResult
    public func changeWlanScheduleStatus(
        wlanIfc: String,
        wlanAp: String,
        status: WlanScheduleStatus,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        client.requestFeature(
            id: .wlanScheduleEnable,
            pathVariables: ["wlan_ifc": wlanIfc, "wlan_ap": wlanAp.removingColons],
            method: .put,
            body: status
        ) { (result: Result<EmptyResponse, LiveboxError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
