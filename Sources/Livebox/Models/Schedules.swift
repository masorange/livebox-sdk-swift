/// A list of schedule slots.
public typealias Schedules = [Schedule]

/// A day of the week, starting on Monday.
public enum Weekday: Int, Codable, CaseIterable, CustomStringConvertible {
    /// Monday.
    case monday = 1
    /// Tuesday.
    case tuesday
    /// Wednesday.
    case wednesday
    /// Thursday.
    case thursday
    /// Friday.
    case friday
    /// Saturday.
    case saturday
    /// Sunday.
    case sunday

    /// The English name of the day.
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

/// A type-safe identifier for a 1-hour time slot in a week.
///
/// Values range from 1 to 168, where:
/// - 1 represents Monday 00:00-01:00.
/// - 168 represents Sunday 23:00-00:00.
///
/// The router sends and receives the identifier as a string (for example, `"25"`).
public struct ScheduleID: RawRepresentable, Codable, Hashable, Sendable {
    /// The slot number, from 1 to 168.
    public let rawValue: Int

    /// Creates a schedule ID from a slot number.
    /// - Parameter rawValue: The slot number, from 1 to 168.
    /// - Returns: `nil` if `rawValue` is out of range.
    public init?(rawValue: Int) {
        guard (1...168).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }

    /// Creates a schedule ID for a specific day and hour.
    /// - Parameters:
    ///   - day: The day of the week.
    ///   - hour: The hour of the day, from 0 to 23.
    /// - Returns: The schedule ID, or `nil` if `hour` is out of range.
    public static func day(_ day: Weekday, hour: Int) -> ScheduleID? {
        guard (0...23).contains(hour) else { return nil }
        let id = (day.rawValue - 1) * 24 + hour + 1
        return ScheduleID(rawValue: id)
    }

    /// The day of the week of the slot.
    public var dayOfWeek: Weekday {
        let dayIndex = ((rawValue - 1) / 24) + 1
        return Weekday(rawValue: dayIndex)!
    }

    /// The hour of the day the slot starts at, from 0 to 23.
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
    /// Creates a schedule ID from an integer literal.
    ///
    /// - Important: The program traps if `value` is not between 1 and 168.
    ///   Use ``init(rawValue:)`` for values that aren't known at compile time.
    public init(integerLiteral value: Int) {
        guard let scheduleID = ScheduleID(rawValue: value) else {
            fatalError("Invalid schedule ID: \(value). Must be between 1 and 168.")
        }
        self = scheduleID
    }
}

extension ScheduleID: Comparable {
    /// Orders schedule IDs chronologically, from Monday 00:00 to Sunday 23:00.
    public static func < (lhs: ScheduleID, rhs: ScheduleID) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension ScheduleID: CustomStringConvertible {
    /// A readable description of the slot, for example `"Monday 08:00-09:00"`.
    public var description: String {
        "\(dayOfWeek) \(String(format: "%02d", hourOfDay)):00-\(String(format: "%02d", hourOfDay + 1)):00"
    }
}

// MARK: - Predefined Constants

extension ScheduleID {
    /// The first slot of the week: Monday 00:00-01:00.
    public static let mondayMidnight: ScheduleID = 1

    /// The last slot of the week: Sunday 23:00-00:00.
    public static let sundayLastHour: ScheduleID = 168

    /// Returns the 24 schedule IDs of a day.
    /// - Parameter day: The day of the week.
    /// - Returns: The schedule IDs of the day, from 00:00 to 23:00.
    public static func allHours(for day: Weekday) -> [ScheduleID] {
        return (0..<24).compactMap { hour in
            ScheduleID.day(day, hour: hour)
        }
    }
}

/// A 1-hour slot during which devices have no access to the network.
///
/// Parental control schedules apply to a single device, and Wi-Fi schedules apply to the whole router.
public struct Schedule: Codable {
    /// The time slot of the schedule.
    public let scheduleID: ScheduleID

    /// The slot number as a string.
    ///
    /// Kept for backward compatibility. Use ``scheduleID`` instead.
    public var id: String {
        return String(scheduleID.rawValue)
    }

    private enum CodingKeys: String, CodingKey {
        case scheduleID = "Id"
    }

    /// Creates a schedule for a time slot.
    /// - Parameter scheduleID: The time slot of the schedule.
    public init(scheduleID: ScheduleID) {
        self.scheduleID = scheduleID
    }

    /// Creates a schedule for a specific day and hour.
    /// - Parameters:
    ///   - day: The day of the week.
    ///   - hour: The hour of the day, from 0 to 23.
    /// - Returns: `nil` if `hour` is out of range.
    public init?(day: Weekday, hour: Int) {
        guard let scheduleID = ScheduleID.day(day, hour: hour) else { return nil }
        self.scheduleID = scheduleID
    }
}
