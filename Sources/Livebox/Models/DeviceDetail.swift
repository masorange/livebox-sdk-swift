/// Represents the details of a device connected to the network.
public struct DeviceDetail: Codable {
    /// The MAC address of the device.
    public let physAddress: String
    public let ipAddress: String
    public let ipV6Address: String
    public let addressSource: String?
    public let detectedTypes: String?
    public let leaseTimeRemaining: Int?
    public let vendorClassID: String?
    public let clientID: String?
    public let userClassID: String?
    public let hostName: String
    public let alias: String
    public let uPnPNames: String?
    public let mDNSNames: String?
    public let lLTDDevice: Bool?
    public let SSID: String
    public let active: Bool
    public let lastConnection: String
    public let tags: String
    public let layer2Interface: Int
    public let interfaceType: String
    public let manufacturerOUI: String?
    public let serialNumber: String?
    public let productClass: String?
    public let deviceIcon: String?
    public let deviceLocation: String?
    public let deviceType: String
    public let deviceSource: String?
    public let deviceID: String

    public init(
        physAddress: String,
        ipAddress: String,
        ipV6Address: String,
        addressSource: String? = nil,
        detectedTypes: String? = nil,
        leaseTimeRemaining: Int? = nil,
        vendorClassID: String? = nil,
        clientID: String? = nil,
        userClassID: String? = nil,
        hostName: String,
        alias: String,
        uPnPNames: String? = nil,
        mDNSNames: String? = nil,
        lLTDDevice: Bool? = nil,
        SSID: String,
        active: Bool,
        lastConnection: String,
        tags: String,
        layer2Interface: Int,
        interfaceType: String,
        manufacturerOUI: String? = nil,
        serialNumber: String? = nil,
        productClass: String? = nil,
        deviceIcon: String? = nil,
        deviceLocation: String? = nil,
        deviceType: String,
        deviceSource: String? = nil,
        deviceID: String
    ) {
        self.physAddress = physAddress
        self.ipAddress = ipAddress
        self.ipV6Address = ipV6Address
        self.addressSource = addressSource
        self.detectedTypes = detectedTypes
        self.leaseTimeRemaining = leaseTimeRemaining
        self.vendorClassID = vendorClassID
        self.clientID = clientID
        self.userClassID = userClassID
        self.hostName = hostName
        self.alias = alias
        self.uPnPNames = uPnPNames
        self.mDNSNames = mDNSNames
        self.lLTDDevice = lLTDDevice
        self.SSID = SSID
        self.active = active
        self.lastConnection = lastConnection
        self.tags = tags
        self.layer2Interface = layer2Interface
        self.interfaceType = interfaceType
        self.manufacturerOUI = manufacturerOUI
        self.serialNumber = serialNumber
        self.productClass = productClass
        self.deviceIcon = deviceIcon
        self.deviceLocation = deviceLocation
        self.deviceType = deviceType
        self.deviceSource = deviceSource
        self.deviceID = deviceID
    }
}

extension DeviceDetail {
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
