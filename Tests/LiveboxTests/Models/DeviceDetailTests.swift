import Foundation
import Testing

@testable import Livebox

@Suite("DeviceDetail Tests")
struct DeviceDetailsTests {
    @Test("Decoding DeviceDetail from JSON with all properties")
    func testDecodingCompleteDeviceDetails() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.100",
                "ipV6Address": "2001:db8::1",
                "addressSource": "DHCP",
                "detectedTypes": "Computer,Gaming",
                "leaseTimeRemaining": 3600,
                "vendorClassID": "MSFT 5.0",
                "clientID": "client123",
                "userClassID": "user456",
                "hostName": "MyComputer",
                "alias": "Gaming PC",
                "uPnPNames": "UPnP Device",
                "mDNSNames": "MyComputer.local",
                "lLTDDevice": true,
                "SSID": "MyWiFiNetwork",
                "active": true,
                "lastConnection": "2023-10-15T14:30:00Z",
                "tags": "gaming,work",
                "layer2Interface": 1,
                "interfaceType": "Ethernet",
                "manufacturerOUI": "00:11:22",
                "serialNumber": "SN123456789",
                "productClass": "Desktop",
                "deviceIcon": "computer.png",
                "deviceLocation": "Living Room",
                "deviceType": "Computer",
                "deviceSource": "DHCP",
                "deviceID": "device_123"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        // Test required properties
        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.100")
        #expect(deviceDetails.ipV6Address == "2001:db8::1")
        #expect(deviceDetails.hostName == "MyComputer")
        #expect(deviceDetails.alias == "Gaming PC")
        #expect(deviceDetails.SSID == "MyWiFiNetwork")
        #expect(deviceDetails.active == true)
        #expect(deviceDetails.lastConnection == "2023-10-15T14:30:00Z")
        #expect(deviceDetails.tags == "gaming,work")
        #expect(deviceDetails.layer2Interface == 1)
        #expect(deviceDetails.interfaceType == "Ethernet")
        #expect(deviceDetails.deviceType == "Computer")
        #expect(deviceDetails.deviceID == "device_123")

        // Test optional properties
        #expect(deviceDetails.addressSource == "DHCP")
        #expect(deviceDetails.detectedTypes == "Computer,Gaming")
        #expect(deviceDetails.leaseTimeRemaining == 3600)
        #expect(deviceDetails.vendorClassID == "MSFT 5.0")
        #expect(deviceDetails.clientID == "client123")
        #expect(deviceDetails.userClassID == "user456")
        #expect(deviceDetails.uPnPNames == "UPnP Device")
        #expect(deviceDetails.mDNSNames == "MyComputer.local")
        #expect(deviceDetails.lLTDDevice == true)
        #expect(deviceDetails.manufacturerOUI == "00:11:22")
        #expect(deviceDetails.serialNumber == "SN123456789")
        #expect(deviceDetails.productClass == "Desktop")
        #expect(deviceDetails.deviceIcon == "computer.png")
        #expect(deviceDetails.deviceLocation == "Living Room")
        #expect(deviceDetails.deviceSource == "DHCP")
    }

    @Test("Decoding DeviceDetail from JSON with minimal properties")
    func testDecodingMinimalDeviceDetails() throws {
        let json = """
            {
                "physAddress": "11:22:33:44:55:66",
                "ipAddress": "192.168.1.50",
                "ipV6Address": "",
                "hostName": "",
                "alias": "",
                "SSID": "",
                "active": false,
                "lastConnection": "",
                "tags": "",
                "layer2Interface": 0,
                "interfaceType": "WiFi",
                "deviceType": "Unknown",
                "deviceID": "device_456"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        // Test required properties
        #expect(deviceDetails.physAddress == "11:22:33:44:55:66")
        #expect(deviceDetails.ipAddress == "192.168.1.50")
        #expect(deviceDetails.ipV6Address == "")
        #expect(deviceDetails.hostName == "")
        #expect(deviceDetails.alias == "")
        #expect(deviceDetails.SSID == "")
        #expect(deviceDetails.active == false)
        #expect(deviceDetails.lastConnection == "")
        #expect(deviceDetails.tags == "")
        #expect(deviceDetails.layer2Interface == 0)
        #expect(deviceDetails.interfaceType == "WiFi")
        #expect(deviceDetails.deviceType == "Unknown")
        #expect(deviceDetails.deviceID == "device_456")

        // Test optional properties are nil
        #expect(deviceDetails.addressSource == nil)
        #expect(deviceDetails.detectedTypes == nil)
        #expect(deviceDetails.leaseTimeRemaining == nil)
        #expect(deviceDetails.vendorClassID == nil)
        #expect(deviceDetails.clientID == nil)
        #expect(deviceDetails.userClassID == nil)
        #expect(deviceDetails.uPnPNames == nil)
        #expect(deviceDetails.mDNSNames == nil)
        #expect(deviceDetails.lLTDDevice == nil)
        #expect(deviceDetails.manufacturerOUI == nil)
        #expect(deviceDetails.serialNumber == nil)
        #expect(deviceDetails.productClass == nil)
        #expect(deviceDetails.deviceIcon == nil)
        #expect(deviceDetails.deviceLocation == nil)
        #expect(deviceDetails.deviceSource == nil)
    }

    @Test("Decoding DeviceDetail with WiFi interface type")
    func testDecodingWiFiDeviceDetails() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.200",
                "ipV6Address": "fe80::1",
                "hostName": "iPhone-John",
                "alias": "John's Phone",
                "SSID": "HomeWiFi",
                "active": true,
                "lastConnection": "2023-10-15T16:45:00Z",
                "tags": "mobile,personal",
                "layer2Interface": 2,
                "interfaceType": "Wifi",
                "deviceType": "Smartphone",
                "deviceID": "iphone_001"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.200")
        #expect(deviceDetails.ipV6Address == "fe80::1")
        #expect(deviceDetails.hostName == "iPhone-John")
        #expect(deviceDetails.alias == "John's Phone")
        #expect(deviceDetails.SSID == "HomeWiFi")
        #expect(deviceDetails.active == true)
        #expect(deviceDetails.lastConnection == "2023-10-15T16:45:00Z")
        #expect(deviceDetails.tags == "mobile,personal")
        #expect(deviceDetails.layer2Interface == 2)
        #expect(deviceDetails.interfaceType == "Wifi")
        #expect(deviceDetails.deviceType == "Smartphone")
        #expect(deviceDetails.deviceID == "iphone_001")
    }

    @Test("Encoding DeviceDetails to JSON")
    func testEncodingDeviceDetails() throws {
        let deviceDetails = DeviceDetail(
            physAddress: "AA:BB:CC:DD:EE:FF",
            ipAddress: "192.168.1.100",
            ipV6Address: "2001:db8::1",
            addressSource: "DHCP",
            detectedTypes: "Computer",
            leaseTimeRemaining: 3600,
            vendorClassID: "MSFT 5.0",
            clientID: "client123",
            userClassID: "user456",
            hostName: "TestDevice",
            alias: "Test Device",
            uPnPNames: "UPnP Device",
            mDNSNames: "TestDevice.local",
            lLTDDevice: true,
            SSID: "TestWiFi",
            active: true,
            lastConnection: "2023-10-15T14:30:00Z",
            tags: "test,device",
            layer2Interface: 1,
            interfaceType: "Ethernet",
            manufacturerOUI: "00:11:22",
            serialNumber: "SN123456789",
            productClass: "Desktop",
            deviceIcon: "computer.png",
            deviceLocation: "Office",
            deviceType: "Computer",
            deviceSource: "DHCP",
            deviceID: "test_device_123"
        )

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(deviceDetails)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // Test required properties
        #expect(encodedJson["physAddress"] as? String == "AA:BB:CC:DD:EE:FF")
        #expect(encodedJson["ipAddress"] as? String == "192.168.1.100")
        #expect(encodedJson["ipV6Address"] as? String == "2001:db8::1")
        #expect(encodedJson["hostName"] as? String == "TestDevice")
        #expect(encodedJson["alias"] as? String == "Test Device")
        #expect(encodedJson["SSID"] as? String == "TestWiFi")
        #expect(encodedJson["active"] as? Bool == true)
        #expect(encodedJson["lastConnection"] as? String == "2023-10-15T14:30:00Z")
        #expect(encodedJson["tags"] as? String == "test,device")
        #expect(encodedJson["layer2Interface"] as? Int == 1)
        #expect(encodedJson["interfaceType"] as? String == "Ethernet")
        #expect(encodedJson["deviceType"] as? String == "Computer")
        #expect(encodedJson["deviceID"] as? String == "test_device_123")

        // Test optional properties
        #expect(encodedJson["addressSource"] as? String == "DHCP")
        #expect(encodedJson["detectedTypes"] as? String == "Computer")
        #expect(encodedJson["leaseTimeRemaining"] as? Int == 3600)
        #expect(encodedJson["vendorClassID"] as? String == "MSFT 5.0")
        #expect(encodedJson["clientID"] as? String == "client123")
        #expect(encodedJson["userClassID"] as? String == "user456")
        #expect(encodedJson["uPnPNames"] as? String == "UPnP Device")
        #expect(encodedJson["mDNSNames"] as? String == "TestDevice.local")
        #expect(encodedJson["lLTDDevice"] as? Bool == true)
        #expect(encodedJson["manufacturerOUI"] as? String == "00:11:22")
        #expect(encodedJson["serialNumber"] as? String == "SN123456789")
        #expect(encodedJson["productClass"] as? String == "Desktop")
        #expect(encodedJson["deviceIcon"] as? String == "computer.png")
        #expect(encodedJson["deviceLocation"] as? String == "Office")
        #expect(encodedJson["deviceSource"] as? String == "DHCP")
    }

    @Test("Decoding DeviceDetail with empty optional fields")
    func testDecodingWithEmptyOptionalFields() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.150",
                "ipV6Address": "2001:db8::150",
                "hostName": "EmptyOptionalDevice",
                "alias": "Test Device with Empty Optionals",
                "SSID": "TestNetwork",
                "active": true,
                "lastConnection": "2023-10-15T18:00:00Z",
                "tags": "test",
                "layer2Interface": 1,
                "interfaceType": "Ethernet",
                "deviceType": "Computer",
                "deviceID": "empty_optional_device"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.150")
        #expect(deviceDetails.ipV6Address == "2001:db8::150")
        #expect(deviceDetails.hostName == "EmptyOptionalDevice")
        #expect(deviceDetails.alias == "Test Device with Empty Optionals")
        #expect(deviceDetails.SSID == "TestNetwork")
        #expect(deviceDetails.active == true)
        #expect(deviceDetails.lastConnection == "2023-10-15T18:00:00Z")
        #expect(deviceDetails.tags == "test")
        #expect(deviceDetails.layer2Interface == 1)
        #expect(deviceDetails.interfaceType == "Ethernet")
        #expect(deviceDetails.deviceType == "Computer")
        #expect(deviceDetails.deviceID == "empty_optional_device")

        // All optional fields should be nil
        #expect(deviceDetails.addressSource == nil)
        #expect(deviceDetails.detectedTypes == nil)
        #expect(deviceDetails.leaseTimeRemaining == nil)
        #expect(deviceDetails.vendorClassID == nil)
        #expect(deviceDetails.clientID == nil)
        #expect(deviceDetails.userClassID == nil)
        #expect(deviceDetails.uPnPNames == nil)
        #expect(deviceDetails.mDNSNames == nil)
        #expect(deviceDetails.lLTDDevice == nil)
        #expect(deviceDetails.manufacturerOUI == nil)
        #expect(deviceDetails.serialNumber == nil)
        #expect(deviceDetails.productClass == nil)
        #expect(deviceDetails.deviceIcon == nil)
        #expect(deviceDetails.deviceLocation == nil)
        #expect(deviceDetails.deviceSource == nil)
    }

    @Test("Decoding DeviceDetail with special characters")
    func testDecodingWithSpecialCharacters() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.175",
                "ipV6Address": "2001:db8::175",
                "hostName": "Café's-Device_123",
                "alias": "Señor García's Smart TV (Living Room)",
                "SSID": "WiFi-Network_2.4GHz",
                "active": true,
                "lastConnection": "2023-10-15T20:15:30Z",
                "tags": "ñoño,café,español",
                "layer2Interface": 2,
                "interfaceType": "WiFi/Ethernet",
                "deviceType": "Smart TV",
                "deviceID": "special_chars_device_äöü"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.175")
        #expect(deviceDetails.ipV6Address == "2001:db8::175")
        #expect(deviceDetails.hostName == "Café's-Device_123")
        #expect(deviceDetails.alias == "Señor García's Smart TV (Living Room)")
        #expect(deviceDetails.SSID == "WiFi-Network_2.4GHz")
        #expect(deviceDetails.active == true)
        #expect(deviceDetails.lastConnection == "2023-10-15T20:15:30Z")
        #expect(deviceDetails.tags == "ñoño,café,español")
        #expect(deviceDetails.layer2Interface == 2)
        #expect(deviceDetails.interfaceType == "WiFi/Ethernet")
        #expect(deviceDetails.deviceType == "Smart TV")
        #expect(deviceDetails.deviceID == "special_chars_device_äöü")
    }

    @Test("InterfaceType enum initialization from raw values")
    func testInterfaceTypeEnumInitialization() {
        // Test standard cases
        #expect(DeviceDetail.InterfaceType(rawValue: "Ethernet") == .ethernet)
        #expect(DeviceDetail.InterfaceType(rawValue: "ethernet") == .ethernet)
        #expect(DeviceDetail.InterfaceType(rawValue: "ETHERNET") == .ethernet)

        #expect(DeviceDetail.InterfaceType(rawValue: "Wifi") == .wifi)
        #expect(DeviceDetail.InterfaceType(rawValue: "wifi") == .wifi)
        #expect(DeviceDetail.InterfaceType(rawValue: "WIFI") == .wifi)
        #expect(DeviceDetail.InterfaceType(rawValue: "WiFi") == .wifi)

        // Test unknown/default case
        #expect(DeviceDetail.InterfaceType(rawValue: "Unknown") == .unknown)
        #expect(DeviceDetail.InterfaceType(rawValue: "Powerline") == .unknown)
        #expect(DeviceDetail.InterfaceType(rawValue: "Bluetooth") == .unknown)
        #expect(DeviceDetail.InterfaceType(rawValue: "") == .unknown)
        #expect(DeviceDetail.InterfaceType(rawValue: "SomeOtherType") == .unknown)
    }

    @Test("InterfaceType enum raw values")
    func testInterfaceTypeRawValues() {
        #expect(DeviceDetail.InterfaceType.ethernet.rawValue == "Ethernet")
        #expect(DeviceDetail.InterfaceType.wifi.rawValue == "Wifi")
        #expect(DeviceDetail.InterfaceType.unknown.rawValue == "Unknown")
    }

    @Test("Decoding DeviceDetail with negative lease time")
    func testDecodingWithNegativeLeaseTime() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.180",
                "ipV6Address": "",
                "leaseTimeRemaining": -1,
                "hostName": "StaticDevice",
                "alias": "Static IP Device",
                "SSID": "",
                "active": true,
                "lastConnection": "2023-10-15T21:00:00Z",
                "tags": "static",
                "layer2Interface": 1,
                "interfaceType": "Ethernet",
                "deviceType": "Server",
                "deviceID": "static_device_001"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.180")
        #expect(deviceDetails.leaseTimeRemaining == -1)
        #expect(deviceDetails.hostName == "StaticDevice")
        #expect(deviceDetails.alias == "Static IP Device")
        #expect(deviceDetails.active == true)
        #expect(deviceDetails.deviceType == "Server")
    }

    @Test("Decoding DeviceDetails with large layer2Interface value")
    func testDecodingWithLargeLayer2Interface() throws {
        let json = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.190",
                "ipV6Address": "",
                "hostName": "HighInterfaceDevice",
                "alias": "Device on High Interface",
                "SSID": "",
                "active": false,
                "lastConnection": "2023-10-15T22:00:00Z",
                "tags": "high_interface",
                "layer2Interface": 9999,
                "interfaceType": "Unknown",
                "deviceType": "IoT",
                "deviceID": "high_interface_device"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let deviceDetails = try decoder.decode(DeviceDetail.self, from: jsonData)

        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.ipAddress == "192.168.1.190")
        #expect(deviceDetails.hostName == "HighInterfaceDevice")
        #expect(deviceDetails.alias == "Device on High Interface")
        #expect(deviceDetails.active == false)
        #expect(deviceDetails.layer2Interface == 9999)
        #expect(deviceDetails.interfaceType == "Unknown")
        #expect(deviceDetails.deviceType == "IoT")
        #expect(deviceDetails.deviceID == "high_interface_device")
    }

    @Test("Decoding DeviceDetails with boolean lLTDDevice variations")
    func testDecodingWithBooleanVariations() throws {
        let jsonTrue = """
            {
                "physAddress": "AA:BB:CC:DD:EE:FF",
                "ipAddress": "192.168.1.195",
                "ipV6Address": "",
                "lLTDDevice": true,
                "hostName": "LLTDTrueDevice",
                "alias": "LLTD True Device",
                "SSID": "",
                "active": true,
                "lastConnection": "2023-10-15T23:00:00Z",
                "tags": "lltd_true",
                "layer2Interface": 1,
                "interfaceType": "Ethernet",
                "deviceType": "Computer",
                "deviceID": "lltd_true_device"
            }
            """

        let jsonFalse = """
            {
                "physAddress": "BB:CC:DD:EE:FF:AA",
                "ipAddress": "192.168.1.196",
                "ipV6Address": "",
                "lLTDDevice": false,
                "hostName": "LLTDFalseDevice",
                "alias": "LLTD False Device",
                "SSID": "",
                "active": true,
                "lastConnection": "2023-10-15T23:30:00Z",
                "tags": "lltd_false",
                "layer2Interface": 1,
                "interfaceType": "Ethernet",
                "deviceType": "Computer",
                "deviceID": "lltd_false_device"
            }
            """

        let decoder = JSONDecoder()

        let deviceTrue = try decoder.decode(DeviceDetail.self, from: jsonTrue.data(using: .utf8)!)
        #expect(deviceTrue.lLTDDevice == true)
        #expect(deviceTrue.hostName == "LLTDTrueDevice")

        let deviceFalse = try decoder.decode(DeviceDetail.self, from: jsonFalse.data(using: .utf8)!)
        #expect(deviceFalse.lLTDDevice == false)
        #expect(deviceFalse.hostName == "LLTDFalseDevice")
    }
}
