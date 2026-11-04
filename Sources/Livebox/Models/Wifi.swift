/// The status of a Wi-Fi interface, as returned by the `Wifi` feature (`/API/LAN/WIFI`).
///
/// The response is a list that mixes the Wi-Fi interfaces with an entry for the Wi-Fi status button,
/// which reflects the general Wi-Fi ON/OFF switch of the router web interface:
///
/// ```json
/// [
///   { "WiFiStatusButton": "True" },
///   { "Id": "24GHz", "Status": "Up", "Frequency": "2.4GHz" },
///   { "Id": "5GHz", "Status": "Up", "Frequency": "5GHz" }
/// ]
/// ```
///
/// Both kinds of entries are decoded into this model so the whole list can be decoded as `[Wifi]`.
/// When an entry doesn't include `Id`, `Status` or `Frequency`, they default to an empty string and `unknown`.
/// Use ``isWifiInterface`` or ``Swift/Array/wifiInterfaces`` to keep only the real interfaces.
public struct Wifi: Codable {
    /// Whether the router's Wi-Fi is enabled through the general ON/OFF switch of the web interface,
    /// or `nil` if this entry is a Wi-Fi interface.
    ///
    /// Decoded from a boolean or from the strings `"True"` and `"False"`, ignoring case.
    public let wifiStatusButton: Bool?

    /// The interface identifier (for example, `"24GHz"`), used as `wlanIfc` in other requests.
    ///
    /// Empty if this entry is the Wi-Fi status button.
    public let id: String

    /// The status of the interface.
    public let status: Status

    /// The frequency band of the interface.
    public let frequency: Frequency

    /// Whether this entry is a Wi-Fi interface rather than the Wi-Fi status button.
    public var isWifiInterface: Bool {
        return wifiStatusButton == nil && !id.isEmpty
    }

    private enum CodingKeys: String, CodingKey {
        case wifiStatusButton = "WiFiStatusButton"
        case id = "Id"
        case status = "Status"
        case frequency = "Frequency"
    }

    /// Creates a Wi-Fi interface status.
    /// - Parameters:
    ///   - id: The interface identifier.
    ///   - status: The status of the interface.
    ///   - frequency: The frequency band of the interface.
    ///   - wifiStatusButton: The state of the Wi-Fi status button. Pass `nil` for an interface entry.
    public init(id: String, status: Status, frequency: Frequency, wifiStatusButton: Bool? = nil) {
        self.id = id
        self.status = status
        self.frequency = frequency
        self.wifiStatusButton = wifiStatusButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle wifiStatusButton which can be either Bool or String ("true" / "false")
        do {
            if let boolValue = try container.decodeIfPresent(Bool.self, forKey: .wifiStatusButton) {
                wifiStatusButton = boolValue
            } else {
                wifiStatusButton = nil
            }
        } catch DecodingError.typeMismatch {
            let stringValue = try container.decode(String.self, forKey: .wifiStatusButton)
            wifiStatusButton = stringValue.lowercased() == "true"
        }

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        status = try container.decodeIfPresent(Status.self, forKey: .status) ?? .unknown
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .unknown
    }
}

extension Wifi {
    /// The status of a Wi-Fi interface.
    public enum Status: String, Codable {
        /// The interface is enabled.
        case up = "Up"
        /// The interface is disabled.
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

extension Wifi {
    /// The frequency band of a Wi-Fi interface.
    public enum Frequency: String, Codable {
        /// The 2.4 GHz band.
        case _2_4GHz = "2.4GHz"
        /// The 5 GHz band.
        case _5GHz = "5GHz"
        /// The 6 GHz band.
        case _6GHz = "6GHz"
        /// The band is missing or not recognized.
        case unknown = "Unknown"

        /// Creates a frequency from its raw value, ignoring case.
        ///
        /// Unrecognized values are mapped to ``unknown``, so this initializer never returns `nil`.
        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "2.4ghz":
                self = ._2_4GHz
            case "5ghz":
                self = ._5GHz
            case "6ghz":
                self = ._6GHz
            default:
                self = .unknown
            }
        }
    }
}

/// Helpers for the list returned by ``LiveboxAPI/getWifiInterfaces(completion:)``.
extension Array where Element == Wifi {
    /// The Wi-Fi interfaces in the list, without the Wi-Fi status button entry.
    public var wifiInterfaces: [Wifi] {
        return self.filter { $0.isWifiInterface }
    }
}
