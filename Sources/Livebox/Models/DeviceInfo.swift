public struct DeviceInfo: Codable {
    public let physAddress: String
    public let ipAddress: String
    public let ipV6Address: String
    public let hostName: String
    public let alias: String
    public let interfaceType: String
    public let active: Bool

    public init(
        physAddress: String,
        ipAddress: String,
        ipV6Address: String,
        hostName: String,
        alias: String,
        interfaceType: String,
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
