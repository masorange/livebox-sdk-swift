public struct DeviceInfo: Codable {
    public let physAddress: String
    public let ipAddress: String
    public let ipV6Address: String
    public let hostName: String
    public let alias: String
    public let interfaceType: String
    public let active: Bool
}
