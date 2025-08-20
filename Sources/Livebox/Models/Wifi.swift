/// Represents the WiFi status of an interface on the Livebox router.
/// To future developers: this model is designed to match the JSON structure returned by the Livebox API.
/// The /API/LAN/WIFI endpoint returns a list of WiFi interfaces with their id, status and frequency,
/// along with a key for the WiFi status button.
/// An example response might look like this:
/// ```json
/// [
///   {
///     "WiFiStatusButton": true
///   },
///   {
///     "Id": "24GHz",
///     "Status": "Up",
///     "Frequency": "2.4GHz"
///   },
///   {
///     "Id": "5GHz",
///     "Status": "Up",
///     "Frequency": "5GHz"
///   }
/// ]
/// ```
/// Thats why I decided to merge the WiFiStatusButton, Id, Status and Frequency properties into a single model.
/// Using default values for the `id`, `status`, and `frequency` properties should be safe here,
/// as the Livebox API guarantees that these fields will always be present in the response unless
/// `WiFiStatusButton` is `"Down"`. In that case, it wouldn't matter because the /API/LAN/WIFI
/// service wouldn't be accessible.
public struct Wifi: Codable {
    public let wifiStatusButton: Bool?
    public let id: String
    public let status: Status
    public let frequency: Frequency

    /// Returns true if this object represents a valid WiFi interface with all required fields.
    /// Use this to filter out objects like WiFiStatusButton.
    public var isWifiInterface: Bool {
        return wifiStatusButton == nil && !id.isEmpty
    }

    private enum CodingKeys: String, CodingKey {
        case wifiStatusButton = "WiFiStatusButton"
        case id = "Id"
        case status = "Status"
        case frequency = "Frequency"
    }

    init(id: String, status: Status, frequency: Frequency, wifiStatusButton: Bool? = nil) {
        self.id = id
        self.status = status
        self.frequency = frequency
        self.wifiStatusButton = wifiStatusButton
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        wifiStatusButton = try container.decodeIfPresent(Bool.self, forKey: .wifiStatusButton)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        status = try container.decodeIfPresent(Status.self, forKey: .status) ?? .unknown
        frequency = try container.decodeIfPresent(Frequency.self, forKey: .frequency) ?? .unknown
    }
}

extension Wifi {
    /// Represents the status of a WiFi interface.
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

extension Wifi {
    public enum Frequency: String, Codable {
        case _2_4GHz = "2.4GHz"
        case _5GHz = "5GHz"
        case _6GHz = "6GHz"
        case unknown = "Unknown"

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

extension Array where Element == Wifi {
    /// Returns only the valid WiFi interfaces, filtering out items like WiFiStatusButton.
    public var wifiInterfaces: [Wifi] {
        return self.filter { $0.isWifiInterface }
    }
}
