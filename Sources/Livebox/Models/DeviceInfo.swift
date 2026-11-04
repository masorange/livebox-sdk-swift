/// A summary of a device known by the router, as returned by ``LiveboxAPI/getConnectedDevices(completion:)``.
///
/// Use ``LiveboxAPI/getDeviceDetail(mac:completion:)`` to get the full details of a device.
public struct DeviceInfo: Codable {
    /// The MAC address of the device.
    public let physAddress: String
    /// The IPv4 address of the device.
    public let ipAddress: String?
    /// The IPv6 address of the device.
    public let ipV6Address: String?
    /// The host name reported by the device.
    public let hostName: String
    /// The name given to the device on the router.
    public let alias: String
    /// The type of interface the device is connected through.
    public let interfaceType: InterfaceType
    /// Whether the device is currently connected.
    public let active: Bool

    /// Creates a device summary.
    ///
    /// Each parameter sets the property with the same name.
    public init(
        physAddress: String,
        ipAddress: String?,
        ipV6Address: String?,
        hostName: String,
        alias: String,
        interfaceType: InterfaceType,
        active: Bool
    ) {
        self.physAddress = physAddress
        self.ipAddress = ipAddress
        self.ipV6Address = ipV6Address
        self.hostName = hostName
        self.alias = alias
        self.interfaceType = interfaceType
        self.active = active
    }
}

extension DeviceInfo {
    /// The type of interface a device is connected through.
    public enum InterfaceType: String, Codable {
        /// A wired Ethernet connection.
        case ethernet = "Ethernet"
        /// A Wi-Fi connection on an unspecified band.
        case wifi = "Wifi"
        /// A Wi-Fi connection on the 2.4 GHz band.
        case wifi24 = "Wifi24"
        /// A Wi-Fi connection on the 5 GHz band.
        case wifi50 = "Wifi50"
        /// A Wi-Fi connection on the 6 GHz band.
        case wifi60 = "Wifi60"
        /// The interface type is not recognized.
        case unknown = "Unknown"

        /// Creates an interface type from its raw value, ignoring case.
        ///
        /// Unrecognized values are mapped to ``unknown``, so this initializer never returns `nil`.
        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "ethernet":
                self = .ethernet
            case "wifi":
                self = .wifi
            case "wifi24":
                self = .wifi24
            case "wifi50":
                self = .wifi50
            case "wifi60":
                self = .wifi60
            default:
                self = .unknown
            }
        }
    }
}
