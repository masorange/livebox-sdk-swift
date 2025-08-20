import Foundation
import Testing

@testable import Livebox

@Suite("Schedule Tests")
struct ScheduleTests {
    @Test("Decoding Schedule from JSON")
    func testDecodingSchedule() throws {
        let json = """
            {
                "Id": "1"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let schedule = try decoder.decode(Schedule.self, from: jsonData)

        #expect(schedule.id == "1")
        #expect(schedule.scheduleID.rawValue == 1)
    }

    @Test("Decoding Schedule with different ID values", arguments: ["1", "24", "48", "168"])
    func testDecodingScheduleWithDifferentIds(idValue: String) throws {
        let json = """
            {
                "Id": "\(idValue)"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let schedule = try decoder.decode(Schedule.self, from: jsonData)

        #expect(schedule.id == idValue)
        #expect(schedule.scheduleID.rawValue == Int(idValue))
    }

    @Test("Decoding Schedules array from JSON")
    func testDecodingSchedulesArray() throws {
        let json = """
            [
                {
                    "Id": "1"
                },
                {
                    "Id": "24"
                },
                {
                    "Id": "168"
                }
            ]
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let schedules = try decoder.decode(Schedules.self, from: jsonData)

        #expect(schedules.count == 3)
        #expect(schedules[0].id == "1")
        #expect(schedules[1].id == "24")
        #expect(schedules[2].id == "168")
        #expect(schedules[0].scheduleID.rawValue == 1)
        #expect(schedules[1].scheduleID.rawValue == 24)
        #expect(schedules[2].scheduleID.rawValue == 168)
    }

    @Test("Decoding empty Schedules array from JSON")
    func testDecodingEmptySchedulesArray() throws {
        let json = "[]"

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let schedules = try decoder.decode(Schedules.self, from: jsonData)

        #expect(schedules.isEmpty)
    }

    @Test("Encoding Schedule to JSON")
    func testEncodingSchedule() throws {
        let schedule = Schedule(scheduleID: ScheduleID(rawValue: 42)!)

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(schedule)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["Id"] as? String == "42")
    }

    @Test("Encoding Schedules array to JSON")
    func testEncodingSchedulesArray() throws {
        let schedules: Schedules = [
            Schedule(scheduleID: ScheduleID(rawValue: 1)!),
            Schedule(scheduleID: ScheduleID(rawValue: 168)!),
        ]

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(schedules)
        let encodedArray = try JSONSerialization.jsonObject(with: encodedData) as! [[String: Any]]

        #expect(encodedArray.count == 2)
        #expect(encodedArray[0]["Id"] as? String == "1")
        #expect(encodedArray[1]["Id"] as? String == "168")
    }

    @Test("Schedule ID represents hour ranges correctly")
    func testScheduleIdMeaning() throws {
        // Test boundary values based on the documentation
        // Id = "1" represents the first range 0h-1h of Monday
        // Id = "168" represents the period 23h-0h of Sunday

        let mondayFirstHour = Schedule(scheduleID: ScheduleID(rawValue: 1)!)
        let sundayLastHour = Schedule(scheduleID: ScheduleID(rawValue: 168)!)
        let midWeek = Schedule(scheduleID: ScheduleID(rawValue: 84)!)  // Roughly middle of the week

        #expect(mondayFirstHour.id == "1")
        #expect(sundayLastHour.id == "168")
        #expect(midWeek.id == "84")

        // Test day/hour calculation
        #expect(mondayFirstHour.scheduleID.dayOfWeek == .monday)  // Monday
        #expect(mondayFirstHour.scheduleID.hourOfDay == 0)  // 0h-1h
        #expect(sundayLastHour.scheduleID.dayOfWeek == .sunday)  // Sunday
        #expect(sundayLastHour.scheduleID.hourOfDay == 23)  // 23h-0h
    }

    @Test("Decoding Schedule with numeric string IDs")
    func testDecodingScheduleWithNumericStringIds() throws {
        let numericIds = ["001", "024", "100", "168"]
        let expectedValues = [1, 24, 100, 168]

        for (idValue, expectedValue) in zip(numericIds, expectedValues) {
            let json = """
                {
                    "Id": "\(idValue)"
                }
                """

            let jsonData = json.data(using: .utf8)!

            let decoder = JSONDecoder()
            let schedule = try decoder.decode(Schedule.self, from: jsonData)

            #expect(schedule.scheduleID.rawValue == expectedValue)
            #expect(schedule.id == String(expectedValue))
        }
    }

    @Test("Schedule typealias works correctly")
    func testSchedulesTypealias() throws {
        let schedule1 = Schedule(scheduleID: ScheduleID(rawValue: 1)!)
        let schedule2 = Schedule(scheduleID: ScheduleID(rawValue: 2)!)

        let schedules: Schedules = [schedule1, schedule2]
        let explicitArray: [Schedule] = [schedule1, schedule2]

        // Verify that Schedules is indeed [Schedule]
        #expect(schedules.count == explicitArray.count)
        #expect(schedules[0].id == explicitArray[0].id)
        #expect(schedules[1].id == explicitArray[1].id)
        #expect(schedules[0].scheduleID.rawValue == explicitArray[0].scheduleID.rawValue)
        #expect(schedules[1].scheduleID.rawValue == explicitArray[1].scheduleID.rawValue)
    }

    @Test("Decoding fails with missing Id field")
    func testDecodingFailsWithMissingId() throws {
        let json = """
            {
                "NotId": "1"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            try decoder.decode(Schedule.self, from: jsonData)
        }
    }

    @Test("Decoding fails with invalid ID values", arguments: ["0", "169", "-1", "abc", ""])
    func testDecodingFailsWithInvalidIds(scheduleId: String) throws {
        let json = """
            {
                "Id": "\(scheduleId)"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            try decoder.decode(Schedule.self, from: jsonData)
        }
    }

    @Test("ScheduleID type safety")
    func testScheduleIDTypeSafety() throws {
        // Test valid range
        #expect(ScheduleID(rawValue: 1) != nil)
        #expect(ScheduleID(rawValue: 168) != nil)
        #expect(ScheduleID(rawValue: 84) != nil)

        // Test invalid range
        #expect(ScheduleID(rawValue: 0) == nil)
        #expect(ScheduleID(rawValue: 169) == nil)
        #expect(ScheduleID(rawValue: -1) == nil)
    }

    @Test("ScheduleID day and hour calculation")
    func testScheduleIDDayAndHour() throws {
        // Test Monday first hour (ID 1)
        let mondayFirst = ScheduleID(rawValue: 1)!
        #expect(mondayFirst.dayOfWeek == .monday)
        #expect(mondayFirst.hourOfDay == 0)

        // Test Monday last hour (ID 24)
        let mondayLast = ScheduleID(rawValue: 24)!
        #expect(mondayLast.dayOfWeek == .monday)
        #expect(mondayLast.hourOfDay == 23)

        // Test Tuesday first hour (ID 25)
        let tuesdayFirst = ScheduleID(rawValue: 25)!
        #expect(tuesdayFirst.dayOfWeek == .tuesday)
        #expect(tuesdayFirst.hourOfDay == 0)

        // Test Sunday last hour (ID 168)
        let sundayLast = ScheduleID(rawValue: 168)!
        #expect(sundayLast.dayOfWeek == .sunday)
        #expect(sundayLast.hourOfDay == 23)
    }

    @Test("ScheduleID factory method")
    func testScheduleIDFactoryMethod() throws {
        // Test valid day/hour combinations
        let mondayMidnight = ScheduleID.day(.monday, hour: 0)
        #expect(mondayMidnight?.rawValue == 1)

        let sundayLastHour = ScheduleID.day(.sunday, hour: 23)
        #expect(sundayLastHour?.rawValue == 168)

        let wednesdayNoon = ScheduleID.day(.wednesday, hour: 12)
        #expect(wednesdayNoon?.rawValue == 61)  // (3-1)*24 + 12 + 1
    }

    @Test("Schedule convenience initializer")
    func testScheduleConvenienceInitializer() throws {
        // Test valid day/hour schedule creation
        let mondayMorning = Schedule(day: .monday, hour: 8)
        #expect(mondayMorning != nil)
        #expect(mondayMorning?.scheduleID.dayOfWeek == .monday)
        #expect(mondayMorning?.scheduleID.hourOfDay == 8)
    }

    @Test("ScheduleID constants and helper methods")
    func testScheduleIDConstants() throws {
        #expect(ScheduleID.mondayMidnight.rawValue == 1)
        #expect(ScheduleID.sundayLastHour.rawValue == 168)

        // Test allHours method
        let mondayHours = ScheduleID.allHours(for: .monday)
        #expect(mondayHours.count == 24)
        #expect(mondayHours.first?.rawValue == 1)
        #expect(mondayHours.last?.rawValue == 24)

        let sundayHours = ScheduleID.allHours(for: .sunday)
        #expect(sundayHours.count == 24)
        #expect(sundayHours.first?.rawValue == 145)  // (7-1)*24 + 1
        #expect(sundayHours.last?.rawValue == 168)
    }

    @Test("ScheduleID comparable and description")
    func testScheduleIDComparableAndDescription() throws {
        let early = ScheduleID(rawValue: 1)!
        let late = ScheduleID(rawValue: 168)!

        #expect(early < late)
        #expect(late > early)

        // Test description
        #expect(early.description.contains("Monday"))
        #expect(early.description.contains("00:00-01:00"))
        #expect(late.description.contains("Sunday"))
        #expect(late.description.contains("23:00-24:00"))
    }
}
