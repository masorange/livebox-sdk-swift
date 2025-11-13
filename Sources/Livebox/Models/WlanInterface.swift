public struct WlanInterface: Codable {
    public let id: String
    public let status: Status
    public let frequency: String
    public let lastChangeTime: Int?
    public let lastChange: Int?
    public let accessPoints: [ShortAccessPoint]

    private enum CodingKeys: String, CodingKey {
        case id = "Id"
        case status = "Status"
        case frequency = "Frequency"
        case lastChangeTime = "LastChangeTime"
        case lastChange = "LastChange"
        case accessPoints = "AccessPoints"
    }

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
    public enum Status: String, Codable {
        case up = "Up"
        case down = "Down"
        case unknown = "Unknown"

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
    public struct ShortAccessPoint: Codable {
        /// Index of the access point
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
