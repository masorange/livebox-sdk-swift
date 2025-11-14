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
        #expect(device.interfaceType == .ethernet)
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
        #expect(device.interfaceType == .wifi)
        #expect(device.active == false)
    }

    @Test("Decoding DeviceInfo with null IP addresses")
    func testDecodingWithNullIPs() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": null,
                "ipV6Address": null,
                "hostName": "OfflineDevice",
                "alias": "Offline Device",
                "interfaceType": "Ethernet",
                "active": false
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(device.ipAddress == nil)
        #expect(device.ipV6Address == nil)
        #expect(device.hostName == "OfflineDevice")
        #expect(device.alias == "Offline Device")
        #expect(device.interfaceType == .ethernet)
        #expect(device.active == false)
    }

    @Test("Decoding DeviceInfo with missing IP addresses")
    func testDecodingWithMissingIPs() throws {
        let json = """
            {
                "physAddress": "BB:CC:DD:EE:FF:11",
                "hostName": "NoIPDevice",
                "alias": "Device Without IPs",
                "interfaceType": "WiFi",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let device = try decoder.decode(DeviceInfo.self, from: jsonData)

        #expect(device.physAddress == "BB:CC:DD:EE:FF:11")
        #expect(device.ipAddress == nil)
        #expect(device.ipV6Address == nil)
        #expect(device.hostName == "NoIPDevice")
        #expect(device.alias == "Device Without IPs")
        #expect(device.interfaceType == .wifi)
        #expect(device.active == true)
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
        #expect(devices[0].interfaceType == .ethernet)
        #expect(devices[0].active == true)

        // Second device
        #expect(devices[1].physAddress == "11:22:33:44:55:66")
        #expect(devices[1].ipAddress == "192.168.1.101")
        #expect(devices[1].hostName == "Device2")
        #expect(devices[1].alias == "iPhone")
        #expect(devices[1].interfaceType == .wifi)
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
        #expect(device.interfaceType == .wifi)
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
            interfaceType: .ethernet,
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
        #expect(device.interfaceType == .unknown)
        #expect(device.active == false)
    }

    @Test("InterfaceType enum initialization from raw values")
    func testInterfaceTypeInitialization() {
        // Test ethernet
        #expect(DeviceInfo.InterfaceType(rawValue: "Ethernet")! == .ethernet)
        #expect(DeviceInfo.InterfaceType(rawValue: "ethernet")! == .ethernet)
        #expect(DeviceInfo.InterfaceType(rawValue: "ETHERNET")! == .ethernet)

        // Test wifi
        #expect(DeviceInfo.InterfaceType(rawValue: "Wifi")! == .wifi)
        #expect(DeviceInfo.InterfaceType(rawValue: "wifi")! == .wifi)
        #expect(DeviceInfo.InterfaceType(rawValue: "WIFI")! == .wifi)

        // Test wifi24
        #expect(DeviceInfo.InterfaceType(rawValue: "Wifi24")! == .wifi24)
        #expect(DeviceInfo.InterfaceType(rawValue: "wifi24")! == .wifi24)
        #expect(DeviceInfo.InterfaceType(rawValue: "WIFI24")! == .wifi24)

        // Test wifi50
        #expect(DeviceInfo.InterfaceType(rawValue: "Wifi50")! == .wifi50)
        #expect(DeviceInfo.InterfaceType(rawValue: "wifi50")! == .wifi50)
        #expect(DeviceInfo.InterfaceType(rawValue: "WIFI50")! == .wifi50)

        // Test unknown
        #expect(DeviceInfo.InterfaceType(rawValue: "")! == .unknown)
        #expect(DeviceInfo.InterfaceType(rawValue: "Unknown")! == .unknown)
        #expect(DeviceInfo.InterfaceType(rawValue: "SomeOtherType")! == .unknown)
        #expect(DeviceInfo.InterfaceType(rawValue: "InvalidType")! == .unknown)
    }

    @Test("InterfaceType raw values")
    func testInterfaceTypeRawValues() {
        #expect(DeviceInfo.InterfaceType.ethernet.rawValue == "Ethernet")
        #expect(DeviceInfo.InterfaceType.wifi.rawValue == "Wifi")
        #expect(DeviceInfo.InterfaceType.wifi24.rawValue == "Wifi24")
        #expect(DeviceInfo.InterfaceType.wifi50.rawValue == "Wifi50")
        #expect(DeviceInfo.InterfaceType.unknown.rawValue == "Unknown")
    }

    @Test("Decoding DeviceInfo with Wifi24 interface type")
    func testDecodingWifi24InterfaceType() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.50",
                "ipV6Address": "fe80::1",
                "hostName": "SmartPhone",
                "alias": "2.4GHz Device",
                "interfaceType": "Wifi24",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!
        let device = try JSONDecoder().decode(DeviceInfo.self, from: jsonData)

        #expect(device.interfaceType == .wifi24)
        #expect(device.active == true)
    }

    @Test("Decoding DeviceInfo with Wifi50 interface type")
    func testDecodingWifi50InterfaceType() throws {
        let json = """
            {
                "physAddress": "11:22:33:44:55:66",
                "ipAddress": "192.168.1.60",
                "ipV6Address": null,
                "hostName": "Laptop",
                "alias": "5GHz Device",
                "interfaceType": "Wifi50",
                "active": true
            }
            """

        let jsonData = json.data(using: .utf8)!
        let device = try JSONDecoder().decode(DeviceInfo.self, from: jsonData)

        #expect(device.interfaceType == .wifi50)
        #expect(device.ipV6Address == nil)
        #expect(device.active == true)
    }

    @Test("Decoding DeviceInfo with case-insensitive interface types")
    func testDecodingCaseInsensitiveInterfaceTypes() throws {
        // Test lowercase
        let json1 = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.100",
                "ipV6Address": null,
                "hostName": "Device1",
                "alias": "Test",
                "interfaceType": "wifi24",
                "active": true
            }
            """
        let data1 = json1.data(using: .utf8)!
        let device1 = try JSONDecoder().decode(DeviceInfo.self, from: data1)
        #expect(device1.interfaceType == .wifi24)

        // Test uppercase
        let json2 = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.101",
                "ipV6Address": null,
                "hostName": "Device2",
                "alias": "Test",
                "interfaceType": "WIFI50",
                "active": true
            }
            """
        let data2 = json2.data(using: .utf8)!
        let device2 = try JSONDecoder().decode(DeviceInfo.self, from: data2)
        #expect(device2.interfaceType == .wifi50)
    }

    @Test("Encoding DeviceInfo with null IP addresses")
    func testEncodingWithNullIPs() throws {
        let device = DeviceInfo(
            physAddress: "AA:BB:CC:DD:EE:FF",
            ipAddress: nil,
            ipV6Address: nil,
            hostName: "TestDevice",
            alias: "Test Device",
            interfaceType: .wifi24,
            active: false
        )

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(device)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["physAddress"] as? String == "AA:BB:CC:DD:EE:FF")
        #expect(encodedJson["ipAddress"] == nil)
        #expect(encodedJson["ipV6Address"] == nil)
        #expect(encodedJson["hostName"] as? String == "TestDevice")
        #expect(encodedJson["alias"] as? String == "Test Device")
        #expect(encodedJson["interfaceType"] as? String == "Wifi24")
        #expect(encodedJson["active"] as? Bool == false)
    }

    @Test("Round-trip encoding/decoding with all interface types")
    func testRoundTripAllInterfaceTypes() throws {
        let interfaceTypes: [DeviceInfo.InterfaceType] = [.ethernet, .wifi, .wifi24, .wifi50, .unknown]

        for interfaceType in interfaceTypes {
            let device = DeviceInfo(
                physAddress: "AA:BB:CC:DD:EE:FF",
                ipAddress: "192.168.1.100",
                ipV6Address: "2001:db8::1",
                hostName: "TestDevice",
                alias: "Test",
                interfaceType: interfaceType,
                active: true
            )

            let encodedData = try JSONEncoder().encode(device)
            let decodedDevice = try JSONDecoder().decode(DeviceInfo.self, from: encodedData)

            #expect(decodedDevice.interfaceType == interfaceType)
            #expect(decodedDevice.physAddress == device.physAddress)
        }
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
        #expect(device.interfaceType == .unknown)
        #expect(device.active == true)
    }
}
