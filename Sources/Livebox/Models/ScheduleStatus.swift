public struct ScheduleStatus: Codable {
    public let mac: String
    public let status: Status

    enum CodingKeys: String, CodingKey {
        case mac = "MAC"
        case status = "Status"
    }
}

extension ScheduleStatus {
    public enum Status: String, Codable {
        case enabled = "Enabled"
        case disabled = "Disabled"
    }
}
