public struct DeviceScheduleStatus: Codable {
    public let mac: String
    public let status: Status

    enum CodingKeys: String, CodingKey {
        case mac = "MAC"
        case status = "Status"
    }

    public init(mac: String, status: Status) {
        self.mac = mac
        self.status = status
    }
}

extension DeviceScheduleStatus {
    public enum Status: String, Codable {
        case enabled = "Enabled"
        case disabled = "Disabled"

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "enabled":
                self = .enabled
            case "disabled":
                self = .disabled
            default:
                return nil
            }
        }
    }
}
