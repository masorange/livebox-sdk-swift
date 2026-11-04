/// Whether Wi-Fi schedules are enabled on the router.
///
/// Used by ``LiveboxAPI/getWlanScheduleStatus(wlanIfc:wlanAp:completion:)``
/// and ``LiveboxAPI/changeWlanScheduleStatus(wlanIfc:wlanAp:status:completion:)``.
public struct WlanScheduleStatus: Codable {
    /// Whether Wi-Fi schedules are enabled.
    public let isEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case isEnabled = "Enabled"
    }

    /// Creates a Wi-Fi schedule status.
    /// - Parameter isEnabled: Whether Wi-Fi schedules are enabled.
    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
