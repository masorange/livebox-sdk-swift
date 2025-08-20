/// Represents a collection of schedules for a livebox.
public typealias Schedules = [Schedule]

public enum Weekday: Int, Codable, CaseIterable, CustomStringConvertible {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    public var description: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}

/// A type-safe schedule identifier that represents a 1-hour time slot in a week.
/// Values range from 1 to 168, where:
/// - 1 represents Monday 0h-1h
/// - 168 represents Sunday 23h-0h
public struct ScheduleID: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: Int

    public init?(rawValue: Int) {
        guard (1...168).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    /// Creates a schedule ID for a specific day and hour.
    /// - Parameters:
    ///   - day: Day of the week (1 = Monday, 7 = Sunday)
    ///   - hour: Hour of the day (0-23)
    /// - Returns: A ScheduleID if the parameters are valid, nil otherwise
    public static func day(_ day: Weekday, hour: Int) -> ScheduleID? {
        guard (0...23).contains(hour) else { return nil }
        let id = (day.rawValue - 1) * 24 + hour + 1
        return ScheduleID(rawValue: id)
    }

    /// The day of the week (1 = Monday, 7 = Sunday)
    public var dayOfWeek: Weekday {
        let dayIndex = ((rawValue - 1) / 24) + 1
        return Weekday(rawValue: dayIndex)!
    }

    /// The hour of the day (0-23)
    public var hourOfDay: Int {
        return (rawValue - 1) % 24
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let intValue = Int(stringValue),
            let scheduleID = ScheduleID(rawValue: intValue)
        else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid schedule ID: \(stringValue). Must be between 1 and 168."
            )
        }

        self = scheduleID
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(String(rawValue))
    }
}

// MARK: - Convenience Extensions

extension ScheduleID: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        guard let scheduleID = ScheduleID(rawValue: value) else {
            fatalError("Invalid schedule ID: \(value). Must be between 1 and 168.")
        }
        self = scheduleID
    }
}

extension ScheduleID: Comparable {
    public static func < (lhs: ScheduleID, rhs: ScheduleID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension ScheduleID: CustomStringConvertible {
    public var description: String {
        "\(dayOfWeek) \(String(format: "%02d", hourOfDay)):00-\(String(format: "%02d", hourOfDay + 1)):00"
    }
}

// MARK: - Predefined Constants

extension ScheduleID {
    /// Monday 0h-1h
    public static let mondayMidnight: ScheduleID = 1

    /// Sunday 23h-0h (last slot of the week)
    public static let sundayLastHour: ScheduleID = 168

    /// Creates all schedule IDs for a specific day
    /// - Parameter day: Day of the week (1 = Monday, 7 = Sunday)
    /// - Returns: Array of 24 ScheduleIDs for that day
    public static func allHours(for day: Weekday) -> [ScheduleID] {
        return (0..<24).compactMap { hour in
            ScheduleID.day(day, hour: hour)
        }
    }
}

/// Represents a schedule for a livebox.
public struct Schedule: Codable {
    /// The schedule identifier as a type-safe ScheduleID
    public let scheduleID: ScheduleID

    /// Legacy string representation for backward compatibility
    public var id: String {
        return String(scheduleID.rawValue)
    }

    private enum CodingKeys: String, CodingKey {
        case scheduleID = "Id"
    }

    /// Creates a schedule with a type-safe ScheduleID
    public init(scheduleID: ScheduleID) {
        self.scheduleID = scheduleID
    }

    /// Creates a schedule for a specific day and hour
    /// - Parameters:
    ///   - day: Day of the week (1 = Monday, 7 = Sunday)
    ///   - hour: Hour of the day (0-23)
    public init?(day: Weekday, hour: Int) {
        guard let scheduleID = ScheduleID.day(day, hour: hour) else { return nil }
        self.scheduleID = scheduleID
    }
}
