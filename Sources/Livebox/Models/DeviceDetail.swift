/// The details of a device known by the router, as returned by ``LiveboxAPI/getDeviceDetail(mac:completion:)``.
///
/// All values are read-only except ``alias``. Many of them are not documented by the router API.
public struct DeviceDetail: Codable {
    /// The MAC address of the device.
    public let physAddress: String
    /// The IPv4 address of the device.
    public let ipAddress: String
    /// The IPv6 address of the device.
    public let ipV6Address: String
    /// How the device got its IP address, such as `"DHCP"`. Can be empty.
    public let addressSource: String?
    /// The type of device detected by the router, such as `"Phone"`, `"Television"` or `"Set-Top Box"`.
    public let detectedTypes: String?
    /// The remaining time of the DHCP lease, in seconds.
    public let leaseTimeRemaining: Int?
    /// The DHCP vendor class identifier (option 60) sent by the device.
    public let vendorClassID: String?
    /// The DHCP client identifier (option 61) sent by the device.
    public let clientID: String?
    /// The DHCP user class identifier (option 77) sent by the device.
    public let userClassID: String?
    /// The host name reported by the device.
    public let hostName: String
    /// The name given to the device on the router.
    ///
    /// Change it with ``LiveboxAPI/setDeviceAlias(mac:alias:completion:)``.
    public let alias: String
    /// The names advertised by the device through UPnP.
    public let uPnPNames: String?
    /// The names advertised by the device through mDNS.
    public let mDNSNames: String?
    /// Whether the device supports the Link Layer Topology Discovery (LLTD) protocol.
    public let lLTDDevice: Bool?
    /// The SSID of the Wi-Fi network the device is connected to. Empty for devices connected by cable.
    public let SSID: String
    /// Whether the device is currently connected.
    public let active: Bool
    /// The date of the last connection of the device, in ISO 8601 format (for example, `"2012-02-23T15:32:34Z"`).
    public let lastConnection: String
    /// The tags of the device.
    ///
    /// Not documented by the router API.
    public let tags: String
    /// The layer 2 interface the device is connected to.
    ///
    /// Not documented by the router API.
    public let layer2Interface: Int
    /// The type of interface the device is connected through.
    public let interfaceType: InterfaceType
    /// The Organizationally Unique Identifier (OUI) of the device manufacturer.
    public let manufacturerOUI: String?
    /// The serial number of the device.
    public let serialNumber: String?
    /// The product class of the device.
    public let productClass: String?
    /// The name of the icon assigned to the device in the router web interface.
    public let deviceIcon: String?
    /// The location of the device.
    ///
    /// Not documented by the router API.
    public let deviceLocation: String?
    /// The type of device (for example, a computer or a phone).
    public let deviceType: String
    /// The source of the device information, such as `"network"`.
    public let deviceSource: String?
    /// The identifier of the device on the router.
    public let deviceID: String

    /// Creates the details of a device.
    ///
    /// Each parameter sets the property with the same name.
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
        interfaceType: InterfaceType,
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
