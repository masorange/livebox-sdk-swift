public struct WlanScheduleStatus: Codable {
    public let isEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isEnabled = "Enabled"
    }

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
