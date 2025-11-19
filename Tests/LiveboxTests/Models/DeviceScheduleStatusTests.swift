import Foundation
import Testing

@testable import Livebox

@Suite("DeviceScheduleStatus Tests")
struct DeviceScheduleStatusTests {
    @Test("Decoding DeviceScheduleStatus with enabled status")
    func testDecodingEnabledStatus() throws {
        let json = """
            {
                "MAC": "AA:BB:CC:DD:EE:FF",
                "Status": "Enabled"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let status = try decoder.decode(DeviceScheduleStatus.self, from: jsonData)

        #expect(status.mac == "AA:BB:CC:DD:EE:FF")
        #expect(status.status == .enabled)
    }

    @Test("Decoding DeviceScheduleStatus with disabled status")
    func testDecodingDisabledStatus() throws {
        let json = """
            {
                "MAC": "11:22:33:44:55:66",
                "Status": "Disabled"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let status = try decoder.decode(DeviceScheduleStatus.self, from: jsonData)

        #expect(status.mac == "11:22:33:44:55:66")
        #expect(status.status == .disabled)
    }

    @Test("Encoding DeviceScheduleStatus to JSON")
    func testEncodingDeviceScheduleStatus() throws {
        let status = DeviceScheduleStatus(mac: "AA:BB:CC:DD:EE:FF", status: .enabled)

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(status)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["MAC"] as? String == "AA:BB:CC:DD:EE:FF")
        #expect(encodedJson["Status"] as? String == "Enabled")
    }

    @Test("Status enum initialization from raw values")
    func testStatusEnumInitialization() {
        // Test standard capitalization
        #expect(DeviceScheduleStatus.Status(rawValue: "Enabled") == .enabled)
        #expect(DeviceScheduleStatus.Status(rawValue: "Disabled") == .disabled)

        // Test lowercase
        #expect(DeviceScheduleStatus.Status(rawValue: "enabled") == .enabled)
        #expect(DeviceScheduleStatus.Status(rawValue: "disabled") == .disabled)

        // Test uppercase
        #expect(DeviceScheduleStatus.Status(rawValue: "ENABLED") == .enabled)
        #expect(DeviceScheduleStatus.Status(rawValue: "DISABLED") == .disabled)

        // Test mixed case
        #expect(DeviceScheduleStatus.Status(rawValue: "EnAbLeD") == .enabled)
        #expect(DeviceScheduleStatus.Status(rawValue: "DiSaBlEd") == .disabled)

        // Test invalid values
        #expect(DeviceScheduleStatus.Status(rawValue: "Unknown") == nil)
        #expect(DeviceScheduleStatus.Status(rawValue: "Active") == nil)
        #expect(DeviceScheduleStatus.Status(rawValue: "") == nil)
    }

    @Test("Status enum raw values")
    func testStatusEnumRawValues() {
        #expect(DeviceScheduleStatus.Status.enabled.rawValue == "Enabled")
        #expect(DeviceScheduleStatus.Status.disabled.rawValue == "Disabled")
    }

    @Test("Decoding array of DeviceScheduleStatus")
    func testDecodingArray() throws {
        let json = """
            [
                {
                    "MAC": "AA:BB:CC:DD:EE:FF",
                    "Status": "Enabled"
                },
                {
                    "MAC": "11:22:33:44:55:66",
                    "Status": "disabled"
                },
                {
                    "MAC": "99:88:77:66:55:44",
                    "Status": "ENABLED"
                }
            ]
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let statuses = try decoder.decode([DeviceScheduleStatus].self, from: jsonData)

        #expect(statuses.count == 3)
        #expect(statuses[0].mac == "AA:BB:CC:DD:EE:FF")
        #expect(statuses[0].status == .enabled)
        #expect(statuses[1].mac == "11:22:33:44:55:66")
        #expect(statuses[1].status == .disabled)
        #expect(statuses[2].mac == "99:88:77:66:55:44")
        #expect(statuses[2].status == .enabled)
    }
}
