/// Whether parental control schedules are enabled for a device.
///
/// Used by ``LiveboxAPI/changeDeviceScheduleStatus(mac:status:completion:)``.
public struct DeviceScheduleStatus: Codable {
    /// The MAC address of the device.
    public let mac: String
    /// Whether schedules are enabled for the device.
    public let status: Status

    enum CodingKeys: String, CodingKey {
        case mac = "MAC"
        case status = "Status"
    }

    /// Creates a device schedule status.
    /// - Parameters:
    ///   - mac: The MAC address of the device.
    ///   - status: Whether schedules are enabled for the device.
    public init(mac: String, status: Status) {
        self.mac = mac
        self.status = status
    }
}

extension DeviceScheduleStatus {
    /// The status of the schedules of a device.
    public enum Status: String, Codable {
        /// Schedules are enabled.
        case enabled = "Enabled"
        /// Schedules are disabled.
        case disabled = "Disabled"

        /// Creates a status from its raw value, ignoring case.
        ///
        /// Returns `nil` if the value is not recognized.
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
