public struct DeviceInfo: Codable {
    public let physAddress: String
    public let ipAddress: String?
    public let ipV6Address: String?
    public let hostName: String
    public let alias: String
    public let interfaceType: InterfaceType
    public let active: Bool

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
    public enum InterfaceType: String, Codable {
        case ethernet = "Ethernet"
        case wifi = "Wifi"
        case wifi24 = "Wifi24"
        case wifi50 = "Wifi50"
        case unknown = "Unknown"

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
            default:
                self = .unknown
            }
        }
    }
}
