/// The details of a Wi-Fi interface and its access points, as returned by ``LiveboxAPI/getWlanInterface(wlanIfc:completion:)``.
public struct WlanInterface: Codable {
    /// The interface identifier (for example, `"24GHz"`), used as `wlanIfc` in other requests.
    public let id: String
    /// The status of the interface.
    public let status: Status
    /// The frequency band of the interface (for example, `"2.4GHz"`).
    public let frequency: String
    /// The time of the last status change, as reported by the router.
    public let lastChangeTime: Int?
    /// The time elapsed since the last status change, as reported by the router.
    public let lastChange: Int?
    /// The access points of the interface.
    public let accessPoints: [ShortAccessPoint]

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case status = "Status"
        case frequency = "Frequency"
        case lastChangeTime = "LastChangeTime"
        case lastChange = "LastChange"
        case accessPoints = "AccessPoints"
    }

    /// Creates a Wi-Fi interface.
    ///
    /// Each parameter sets the property with the same name.
    public init(
        id: String,
        status: Status,
        frequency: String,
        lastChangeTime: Int? = nil,
        lastChange: Int? = nil,
        accessPoints: [ShortAccessPoint]
    ) {
        self.id = id
        self.status = status
        self.frequency = frequency
        self.lastChangeTime = lastChangeTime
        self.lastChange = lastChange
        self.accessPoints = accessPoints
    }
}

extension WlanInterface {
    /// The status of a Wi-Fi interface or access point.
    public enum Status: String, Codable {
        /// Enabled.
        case up = "Up"
        /// Disabled.
        case down = "Down"
        /// The status is missing or not recognized.
        case unknown = "Unknown"

        /// Creates a status from its raw value, ignoring case.
        ///
        /// Unrecognized values are mapped to ``unknown``, so this initializer never returns `nil`.
        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "up":
                self = .up
            case "down":
                self = .down
            default:
                self = .unknown
            }
        }
    }
}

extension WlanInterface.Status {
    enum CodingKeys: String, CodingKey {
        case up = "up"
        case down = "down"
        case unknown = "unknown"
    }
}

extension WlanInterface {
    /// A summary of an access point of a Wi-Fi interface.
    ///
    /// Use ``LiveboxAPI/getAccessPoint(wlanIfc:wlanAp:completion:)`` with ``idx`` to get its full configuration.
    public struct ShortAccessPoint: Codable {
        /// The identifier of the access point, used as `wlanAp` in other requests.
        ///
        /// Depending on the manufacturer and the network, routers identify access points either by an index
        /// or by the BSSID without colons. If the response has no `Idx`, it's derived from the BSSID by removing colons.
        public let idx: String

        /// BSSID of the access point
        public let bssid: String

        /// SSID of the access point
        public let ssid: String

        /// Status of the access point
        public let status: Status

        /// Applies for temporal switch on cases, giving the remaining time in minutes.
        /// If the temporal switch is not active, two responses are allowed:
        /// - No value at all
        /// - Value=-1
        public let remainingDuration: Int?

        enum CodingKeys: String, CodingKey {
            case idx = "Idx"
            case bssid = "BSSID"
            case ssid = "SSID"
            case status = "Status"
            case remainingDuration = "RemainingDuration"
        }

        /// Creates an access point summary.
        ///
        /// Each parameter sets the property with the same name.
        public init(
            idx: String,
            bssid: String,
            ssid: String,
            status: Status,
            remainingDuration: Int? = nil
        ) {
            self.idx = idx
            self.bssid = bssid
            self.ssid = ssid
            self.status = status
            self.remainingDuration = remainingDuration
        }

        /// Convenience initializer for backward compatibility.
        /// Derives idx from bssid by removing colons.
        public init(
            bssid: String,
            ssid: String,
            status: Status,
            remainingDuration: Int? = nil
        ) {
            self.init(
                idx: bssid.removingColons,
                bssid: bssid,
                ssid: ssid,
                status: status,
                remainingDuration: remainingDuration
            )
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            bssid = try container.decode(String.self, forKey: .bssid)
            ssid = try container.decode(String.self, forKey: .ssid)
            status = try container.decode(Status.self, forKey: .status)
            remainingDuration = try container.decodeIfPresent(Int.self, forKey: .remainingDuration)

            if let idx = try container.decodeIfPresent(String.self, forKey: .idx) {
                self.idx = idx
            } else {
                // If "Idx" is missing, derive it from BSSID by removing colons
                self.idx = bssid.removingColons
            }
        }
    }
}
