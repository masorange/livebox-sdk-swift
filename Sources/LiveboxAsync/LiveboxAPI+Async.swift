import Foundation
import Livebox

/// A collection of async/await extensions for the LiveboxAPI class.
///
/// This extension provides async alternatives to the callback-based methods in LiveboxAPI,
/// allowing for a more modern, structured concurrency approach while maintaining backward compatibility.
extension LiveboxAPI {
    /// A helper function that executes an async throwing closure and ensures any thrown errors
    /// conform to a specific error type.
    ///
    /// This function is useful when working with Swift's typed throws feature, allowing the caller
    /// to specify the expected error type while executing async operations that may throw untyped errors.
    ///
    /// - Parameters:
    ///   - errorType: The type of error that should be thrown. This parameter is not used directly
    ///                but serves as a type hint for the compiler.
    ///   - body: An async closure that performs the actual work and may throw errors.
    /// - Returns: The success value returned by the body closure.
    /// - Throws: An error of the specified Error type. If the body throws an error that doesn't
    ///           match the expected type, it will be force-cast, which may cause a runtime crash.
    ///
    /// - Warning: This function uses a force cast (`as!`) which will crash if the thrown error
    ///            doesn't match the expected Error type. Ensure that the body closure only throws
    ///            errors of the specified type.
    fileprivate func withErrorType<Success, Error: Swift.Error>(
        _: Error.Type,
        _ body: () async throws -> Success
    ) async throws(Error) -> Success {
        do {
            return try await body()
        } catch {
            throw error as! Error
        }
    }

    /// Authenticates with the router using the provided credentials.
    /// - Parameters:
    ///   - username: Username for authentication (default: "UsrAdmin")
    ///   - password: Password for authentication
    /// - Returns: A boolean indicating whether authentication was successful
    /// - Throws: An error if authentication fails
    public func login(username: String = "UsrAdmin", password: String) async throws(LiveboxError) -> Bool {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                login(username: username, password: password) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Fetches the capabilities of the router using async/await.
    /// - Returns: The router capabilities.
    /// - Throws: An error if the request fails.
    public func getCapabilities() async throws(LiveboxError) -> Capabilities {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                _ = getCapabilities { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Gets the router's general information using async/await.
    /// - Returns: The general information.
    /// - Throws: An error if the request fails.
    public func getGeneralInfo() async throws(LiveboxError) -> GeneralInfo {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                _ = getGeneralInfo { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Reboots the router using async/await.
    /// - Throws: An error if the request fails.
    public func reboot() async throws(LiveboxError) {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                _ = reboot { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Gets the router's Wi-Fi interfaces using async/await.
    /// - Returns: An array of Wi-Fi interfaces.
    /// - Throws: An error if the request fails.
    public func getWifiInterfaces() async throws(LiveboxError) -> [Wifi] {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                _ = getWifiInterfaces { result in
                    switch result {
                    case .success(let interfaces):
                        continuation.resume(returning: interfaces)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    /// Gets a specific router's Wi-Fi interface using async/await.
    /// - Parameter wlanIfc: The ID of the Wi-Fi interface.
    /// - Returns: The requested Wi-Fi interface.
    /// - Throws: An error if the request fails.
    public func getWlanInterface(wlanIfc: String) async throws(LiveboxError) -> WlanInterface {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                _ = getWlanInterface(wlanIfc: wlanIfc) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Gets details of a specific access Wi-Fi point.
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    /// - Returns: The requested access point details.
    /// - Throws: An error if the request fails.
    public func getAccessPoint(wlanIfc: String, wlanAp: String) async throws(LiveboxError) -> AccessPoint {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                getAccessPoint(wlanIfc: wlanIfc, wlanAp: wlanAp) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Updates the details of a specific Wi-Fi access point.
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    ///   - accessPoint: The new details of the access point.
    /// - Returns: The updated access point details.
    /// - Throws: An error if the request fails.
    public func updateAccessPoint(
        wlanIfc: String,
        wlanAp: String,
        accessPoint: AccessPoint
    ) async throws(LiveboxError) -> AccessPoint {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                updateAccessPoint(wlanIfc: wlanIfc, wlanAp: wlanAp, accessPoint: accessPoint) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Retrieves the list of connected devices.
    /// - Returns: An array of connected devices.
    /// - Throws: An error if the request fails.
    public func getConnectedDevices() async throws(LiveboxError) -> [DeviceInfo] {
        try await withErrorType(LiveboxError.self) {
            return try await withCheckedThrowingContinuation { continuation in
                getConnectedDevices { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Retrieves the details of a specific device.
    /// - Parameters:
    ///   - mac: The ID of the device.
    /// - Returns: The details of the device.
    /// - Throws: An error if the request fails.
    public func getDeviceDetail(mac: String) async throws(LiveboxError) -> DeviceDetail {
        try await withErrorType(LiveboxError.self) {
            return try await withCheckedThrowingContinuation { continuation in
                getDeviceDetail(mac: mac) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Sets the alias of a specific device.
    /// - Parameters:
    ///   - mac: The ID of the device.
    ///   - alias: The new alias for the device.
    /// - Returns: The updated details of the device.
    /// - Throws: An error if the request fails.
    public func setDeviceAlias(mac: String, alias: String) async throws(LiveboxError) -> DeviceDetail {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                setDeviceAlias(mac: mac, alias: alias) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Retrieves the schedules of a specific device.
    /// - Parameters:
    ///   - mac: The ID of the device.
    /// - Returns: The schedules of the device.
    /// - Throws: An error if the request fails.
    public func getDeviceSchedules(mac: String) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                getDeviceSchedules(mac: mac) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Adds the schedules of a specific device.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - schedules: The new schedules for the device.
    /// - Throws: An error if the request fails.
    public func addDeviceSchedules(mac: String, schedules: Schedules) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                addDeviceSchedules(mac: mac, schedules: schedules) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Changes the status of a connected device's schedule.
    /// Automatically called by `addDeviceSchedules(_:_:_:)` before adding the schedules.
    /// - Parameters:
    ///   - mac: The MAC of the device.
    ///   - status: The status to set.
    public func changeDeviceScheduleStatus(mac: String, status: DeviceScheduleStatus) async throws(LiveboxError) {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                changeDeviceScheduleStatus(mac: mac, status: status) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Deletes the schedules of a specific device.
    /// - Parameters:
    ///   - mac: The MAC of the device.
    ///   - schedules: The schedules to delete.
    /// - Throws: An error if the request fails.
    public func deleteDeviceSchedules(mac: String, schedules: Schedules) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                deleteDeviceSchedules(mac: mac, schedules: schedules) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Retrieves the schedules from the router.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    /// - Returns: The schedules of the WLAN access point.
    /// - Throws: An error if the request fails.
    public func getWlanSchedules(wlanIfc: String, wlanAp: String) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                getWlanSchedules(wlanIfc: wlanIfc, wlanAp: wlanAp) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Adds schedules to the router.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    ///   - schedules: The schedules to add.
    /// - Returns: The updated schedules of the WLAN access point.
    /// - Throws: An error if the request fails.
    public func addWlanSchedules(wlanIfc: String, wlanAp: String, schedules: Schedules) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                addWlanSchedules(wlanIfc: wlanIfc, wlanAp: wlanAp, schedules: schedules) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Deletes the router's schedule.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    ///   - schedules: The schedules to delete.
    /// - Returns: The updated schedules of the WLAN access point.
    /// - Throws: An error if the request fails.
    public func deleteWlanSchedules(wlanIfc: String, wlanAp: String, schedules: Schedules) async throws(LiveboxError) -> Schedules {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                deleteWlanSchedules(wlanIfc: wlanIfc, wlanAp: wlanAp, schedules: schedules) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Retrieves the router's schedule.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    /// - Returns: The schedule status of the WLAN access point.
    /// - Throws: An error if the request fails.
    public func getWlanScheduleStatus(wlanIfc: String, wlanAp: String) async throws(LiveboxError) -> WlanScheduleStatus {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                getWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }

    /// Changes the router's schedule status.
    ///
    /// - Warning: Despite requiring a WLAN interface and access point ID, this service affects the entire router.
    ///
    /// - Parameters:
    ///   - wlanIfc: The ID of the Wi-Fi interface.
    ///   - wlanAp: The ID of the access point.
    ///   - status: The new schedule status to set.
    /// - Throws: An error if the request fails.
    public func changeWlanScheduleStatus(wlanIfc: String, wlanAp: String, status: WlanScheduleStatus) async throws(LiveboxError) {
        try await withErrorType(LiveboxError.self) {
            try await withCheckedThrowingContinuation { continuation in
                changeWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp, status: status) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
}

// MARK: - Additional Helpers

/// Alias to make it clear this is the async-compatible version of LiveboxAPI
/// This doesn't create a new type, but provides a more expressive way to use the async extensions
public typealias AsyncLiveboxAPI = LiveboxAPI
