import Foundation
import Testing

@testable import Livebox

@Suite("DeviceInfo Tests")
struct DeviceInfoTests {
    @Test("Decoding DeviceInfo from JSON with all properties")
    func testDecodingCompleteDeviceInfo() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.100",
                "ipV6Address": "2001:db8::1",
                "hostName": "MyDevice",
                "alias": "Living Room TV",
                "interfaceType": "Ethernet",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(device.ipAddress == "192.168.1.100")
        #expect(device.ipV6Address == "2001:db8::1")
        #expect(device.hostName == "MyDevice")
        #expect(device.alias == "Living Room TV")
        #expect(device.interfaceType == "Ethernet")
        #expect(device.active == true)
    }

    @Test("Decoding DeviceInfo from JSON with minimal properties")
    func testDecodingMinimalDeviceInfo() throws {
        let json = """
            {
                "physAddress": "11:22:33:44:55:66",
                "ipAddress": "192.168.1.50",
                "ipV6Address": "",
                "hostName": "",
                "alias": "",
                "interfaceType": "WiFi",
                "active": false
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "11:22:33:44:55:66")
        #expect(device.ipAddress == "192.168.1.50")
        #expect(device.ipV6Address == "")
        #expect(device.hostName == "")
        #expect(device.alias == "")
        #expect(device.interfaceType == "WiFi")
        #expect(device.active == false)
    }

    @Test("Decoding DeviceInfo array from JSON")
    func testDecodingDeviceInfoArray() throws {
        let json = """
            [
                {
                    "physAddress": "AA:BB:CC:DD:EE:FF",
                    "ipAddress": "192.168.1.100",
                    "ipV6Address": "2001:db8::1",
                    "hostName": "Device1",
                    "alias": "Smart TV",
                    "interfaceType": "Ethernet",
                    "active": true
                },
                {
                    "physAddress": "11:22:33:44:55:66",
                    "ipAddress": "192.168.1.101",
                    "ipV6Address": "",
                    "hostName": "Device2",
                    "alias": "iPhone",
                    "interfaceType": "WiFi",
                    "active": false
                }
            ]
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let devices = try decoder.decode([DeviceInfo].self, from: jsonData)

        #expect(devices.count == 2)

        // First device
        #expect(devices[0].physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(devices[0].ipAddress == "192.168.1.100")
        #expect(devices[0].hostName == "Device1")
        #expect(devices[0].alias == "Smart TV")
        #expect(devices[0].interfaceType == "Ethernet")
        #expect(devices[0].active == true)

        // Second device
        #expect(devices[1].physAddress == "11:22:33:44:55:66")
        #expect(devices[1].ipAddress == "192.168.1.101")
        #expect(devices[1].hostName == "Device2")
        #expect(devices[1].alias == "iPhone")
        #expect(devices[1].interfaceType == "WiFi")
        #expect(devices[1].active == false)
    }

    @Test("Decoding DeviceInfo with WiFi interface type")
    func testDecodingWiFiDeviceInfo() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.200",
                "ipV6Address": "fe80::1",
                "hostName": "iPhone-John",
                "alias": "John's Phone",
                "interfaceType": "WiFi",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(device.ipAddress == "192.168.1.200")
        #expect(device.ipV6Address == "fe80::1")
        #expect(device.hostName == "iPhone-John")
        #expect(device.alias == "John's Phone")
        #expect(device.interfaceType == "WiFi")
        #expect(device.active == true)
    }

    @Test("Encoding Device to JSON")
    func testEncodingDeviceInfo() throws {
        let device = DeviceInfo(
            physAddress: "AA:BB:CC:DD:EE:FF",
            ipAddress: "192.168.1.100",
            ipV6Address: "2001:db8::1",
            hostName: "TestDevice",
            alias: "Test Device",
            interfaceType: "Ethernet",
            active: true
        )

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(device)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["physAddress"] as? String == "AA:BB:CC:DD:EE:FF")
        #expect(encodedJson["ipAddress"] as? String == "192.168.1.100")
        #expect(encodedJson["ipV6Address"] as? String == "2001:db8::1")
        #expect(encodedJson["hostName"] as? String == "TestDevice")
        #expect(encodedJson["alias"] as? String == "Test Device")
        #expect(encodedJson["interfaceType"] as? String == "Ethernet")
        #expect(encodedJson["active"] as? Bool == true)
    }

    @Test("Decoding DeviceInfo with empty strings")
    func testDecodingDeviceInfoWithEmptyStrings() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "",
                "ipV6Address": "",
                "hostName": "",
                "alias": "",
                "interfaceType": "",
                "active": false
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(device.ipAddress == "")
        #expect(device.ipV6Address == "")
        #expect(device.hostName == "")
        #expect(device.alias == "")
        #expect(device.interfaceType == "")
        #expect(device.active == false)
    }

    @Test("Decoding DeviceInfo with special characters in names")
    func testDecodingDeviceInfoWithSpecialCharacters() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.150",
                "ipV6Address": "2001:db8::150",
                "hostName": "Device-With_Special.Characters",
                "alias": "Café's Smart TV (Living Room)",
                "interfaceType": "Ethernet/WiFi",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(device.ipAddress == "192.168.1.150")
        #expect(device.ipV6Address == "2001:db8::150")
        #expect(device.hostName == "Device-With_Special.Characters")
        #expect(device.alias == "Café's Smart TV (Living Room)")
        #expect(device.interfaceType == "Ethernet/WiFi")
        #expect(device.active == true)
    }
}
