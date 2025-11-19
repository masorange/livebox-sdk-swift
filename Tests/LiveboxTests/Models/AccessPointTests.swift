import Foundation
import Testing

@testable import Livebox

@Suite("AccessPoint Tests")
struct AccessPointTests {
    @Test("Decoding AccessPoint from JSON")
    func testDecoding() throws {
        let json = """
            {
                "idx": "8C19B5F8EDA7",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Livebox-Network",
                "Password": "securePassword123",
                "SSIDAdvertisementEnabled": true,
                "RetryLimit": 3,
                "WMMCapability": true,
                "UAPSDCapability": false,
                "WMMEnable": true,
                "UAPSDEnable": false,
                "MaxStations": 32,
                "APBridgeDisable": false,
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "20MHz",
                "Bandwith": "20MHz",
                "Mode": "11ng",
                "SchedulingAllowed": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let accessPoint = try decoder.decode(AccessPoint.self, from: jsonData)

        // Test basic properties
        #expect(accessPoint.idx == "8C19B5F8EDA7")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.type == .home)
        #expect(accessPoint.manner == .combined)
        #expect(accessPoint.status == .up)
        #expect(accessPoint.ssid == "Livebox-Network")
        #expect(accessPoint.password == "securePassword123")

        // Test optional properties
        #expect(accessPoint.ssidAdvertisementEnabled == true)
        #expect(accessPoint.retryLimit == 3)
        #expect(accessPoint.wmmCapability == true)
        #expect(accessPoint.uapsdCapability == false)
        #expect(accessPoint.wmmEnable == true)
        #expect(accessPoint.uapsdEnable == false)
        #expect(accessPoint.maxStations == 32)
        #expect(accessPoint.apBridgeDisable == false)

        // Test remaining properties
        #expect(accessPoint.channelConf == .auto)
        #expect(accessPoint.channel == 6)
        #expect(accessPoint.bandwidthConf == ._20mhz)
        #expect(accessPoint.bandwidth == "20MHz")
        #expect(accessPoint.mode == "11ng")
        #expect(accessPoint.schedulingAllowed == true)
    }

    @Test("Decoding AccessPoint with missing optional fields")
    func testDecodingWithMissingOptionalFields() throws {
        let json = """
            {
                "idx": "8C19B5F8EDA7",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Livebox-Network",
                "Password": "securePassword123",
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "20MHz",
                "Bandwith": "20MHz",
                "Mode": "11ng",
                "SchedulingAllowed": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let accessPoint = try decoder.decode(AccessPoint.self, from: jsonData)

        // Test required properties
        #expect(accessPoint.idx == "8C19B5F8EDA7")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.type == .home)
        #expect(accessPoint.manner == .combined)
        #expect(accessPoint.status == .up)
        #expect(accessPoint.ssid == "Livebox-Network")
        #expect(accessPoint.password == "securePassword123")

        // Test optional properties are nil
        #expect(accessPoint.ssidAdvertisementEnabled == nil)
        #expect(accessPoint.retryLimit == nil)
        #expect(accessPoint.wmmCapability == nil)
        #expect(accessPoint.uapsdCapability == nil)
        #expect(accessPoint.wmmEnable == nil)
        #expect(accessPoint.uapsdEnable == nil)
        #expect(accessPoint.maxStations == nil)
        #expect(accessPoint.apBridgeDisable == nil)
    }

    @Test("Decoding AccessPoint with alternative key name (Idx)")
    func testDecodingWithAlternativeKeyName() throws {
        // Test with uppercase "Idx" (ZTE router variant)
        let json = """
            {
                "Idx": "8C19B5F8EDA7",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Livebox-Network",
                "Password": "securePassword123",
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "20MHz",
                "Bandwith": "20MHz",
                "Mode": "11ng",
                "SchedulingAllowed": true
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let accessPoint = try decoder.decode(AccessPoint.self, from: jsonData)

        #expect(accessPoint.idx == "8C19B5F8EDA7")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.type == .home)
    }

    @Test("Decoding AccessPoint with case-insensitive enum values")
    func testDecodingCaseInsensitiveEnums() throws {
        let json = """
            {
                "idx": "8C19B5F8EDA7",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "home",
                "Manner": "combined",
                "Status": "up",
                "SSID": "Livebox-Network",
                "Password": "securePassword123",
                "ChannelConf": "auto",
                "Channel": 6,
                "BandwithConf": "20MHz",
                "Bandwith": "20MHz",
                "Mode": "11ng",
                "SchedulingAllowed": true
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let accessPoint = try decoder.decode(AccessPoint.self, from: jsonData)

        #expect(accessPoint.type == .home)
        #expect(accessPoint.manner == .combined)
        #expect(accessPoint.status == .up)
        #expect(accessPoint.channelConf == .auto)
    }

    @Test("Decoding AccessPoint with uppercase enum values")
    func testDecodingUppercaseEnums() throws {
        let json = """
            {
                "idx": "8C19B5F8EDA7",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "GUEST",
                "Manner": "SPLIT",
                "Status": "DOWN",
                "SSID": "Livebox-Guest",
                "Password": "guestPassword123",
                "ChannelConf": "AUTO2",
                "Channel": 11,
                "BandwithConf": "40MHz",
                "Bandwith": "40MHz",
                "SchedulingAllowed": false
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let accessPoint = try decoder.decode(AccessPoint.self, from: jsonData)

        #expect(accessPoint.type == .guest)
        #expect(accessPoint.manner == .split)
        #expect(accessPoint.status == .down)
        #expect(accessPoint.channelConf == .auto2)
    }

    @Test("Encoding AccessPoint to JSON")
    func testEncoding() throws {
        let accessPoint = AccessPoint(
            idx: "8C19B5F8EDA7",
            bssid: "8C:19:B5:F8:ED:A7",
            type: .home,
            manner: .combined,
            status: .up,
            ssid: "Livebox-Network",
            password: "securePassword123",
            ssidAdvertisementEnabled: true,
            retryLimit: 3,
            wmmCapability: true,
            uapsdCapability: false,
            wmmEnable: true,
            uapsdEnable: false,
            maxStations: 32,
            apBridgeDisable: false,
            channelConf: .auto,
            channel: 6,
            bandwidthConf: ._20mhz,
            bandwidth: "20MHz",
            mode: "11ng",
            schedulingAllowed: true
        )

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(accessPoint)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // Test encoding of basic properties
        #expect(encodedJson["idx"] as? String == "8C19B5F8EDA7")
        #expect(encodedJson["BSSID"] as? String == "8C:19:B5:F8:ED:A7")
        #expect(encodedJson["Type"] as? String == "Home")
        #expect(encodedJson["Manner"] as? String == "Combined")
        #expect(encodedJson["Status"] as? String == "Up")
        #expect(encodedJson["SSID"] as? String == "Livebox-Network")
        #expect(encodedJson["Password"] as? String == "securePassword123")

        // Test encoding of optional properties
        #expect(encodedJson["SSIDAdvertisementEnabled"] as? Bool == true)
        #expect(encodedJson["RetryLimit"] as? Int == 3)
        #expect(encodedJson["WMMCapability"] as? Bool == true)
        #expect(encodedJson["UAPSDCapability"] as? Bool == false)
        #expect(encodedJson["WMMEnable"] as? Bool == true)
        #expect(encodedJson["UAPSDEnable"] as? Bool == false)
        #expect(encodedJson["MaxStations"] as? Int == 32)
        #expect(encodedJson["APBridgeDisable"] as? Bool == false)

        // Test encoding of remaining properties
        #expect(encodedJson["ChannelConf"] as? String == "Auto")
        #expect(encodedJson["Channel"] as? Int == 6)
        #expect(encodedJson["BandwithConf"] as? String == "20MHz")
        #expect(encodedJson["Bandwith"] as? String == "20MHz")
        #expect(encodedJson["Mode"] as? String == "11ng")
        #expect(encodedJson["SchedulingAllowed"] as? Bool == true)
    }

    @Test("AccessPointType enum cases")
    func testAccessPointTypeEnum() {
        // Test creation from raw values
        #expect(AccessPoint.AccessPointType(rawValue: "Home")! == .home)
        #expect(AccessPoint.AccessPointType(rawValue: "Guest")! == .guest)
        #expect(AccessPoint.AccessPointType(rawValue: "Unknown")! == .unknown("Unknown"))

        // Test raw values
        #expect(AccessPoint.AccessPointType.home.rawValue == "Home")
        #expect(AccessPoint.AccessPointType.guest.rawValue == "Guest")
        #expect(AccessPoint.AccessPointType(rawValue: "Unknown")!.rawValue == "Unknown")
    }

    @Test("Manner enum cases")
    func testMannerEnum() {
        // Test creation from raw values
        #expect(AccessPoint.Manner(rawValue: "Combined") == .combined)
        #expect(AccessPoint.Manner(rawValue: "Split") == .split)
        #expect(AccessPoint.Manner(rawValue: "Unknown") == nil)

        // Test raw values
        #expect(AccessPoint.Manner.combined.rawValue == "Combined")
        #expect(AccessPoint.Manner.split.rawValue == "Split")
    }

    @Test("Status enum cases")
    func testStatusEnum() {
        // Test creation from raw values
        #expect(AccessPoint.Status(rawValue: "Up") == .up)
        #expect(AccessPoint.Status(rawValue: "Down") == .down)
        #expect(AccessPoint.Status(rawValue: "Unknown") == nil)

        // Test raw values
        #expect(AccessPoint.Status.up.rawValue == "Up")
        #expect(AccessPoint.Status.down.rawValue == "Down")
    }

    @Test("ChannelConf enum cases")
    func testChannelConfEnum() {
        // Test creation from raw values
        #expect(AccessPoint.ChannelConf(rawValue: "Auto") == .auto)
        #expect(AccessPoint.ChannelConf(rawValue: "Auto1") == .auto1)
        #expect(AccessPoint.ChannelConf(rawValue: "Auto2") == .auto2)
        #expect(AccessPoint.ChannelConf(rawValue: "Unknown") == nil)
    }

    @Test("Creating AccessPoint request")
    func testSetAccessPointRequest() throws {
        // Create a SetAccessPoint request
        let request = TestHelpers.createTestAccessPoint().copy(
            status: .up,
            ssid: "New-Network-Name",
            password: "newPassword456",
            channelConf: .auto,
            bandwidthConf: ._20mhz,
            mode: "11ng"
        )

        // Test basic properties
        #expect(request.status == .up)
        #expect(request.ssid == "New-Network-Name")
        #expect(request.password == "newPassword456")
        #expect(request.channelConf == .auto)
        #expect(request.bandwidthConf == ._20mhz)
        #expect(request.mode == "11ng")

        // Test encoding
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(request)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["Status"] as? String == "Up")
        #expect(encodedJson["SSID"] as? String == "New-Network-Name")
        #expect(encodedJson["Password"] as? String == "newPassword456")
        #expect(encodedJson["ChannelConf"] as? String == "Auto")
        #expect(encodedJson["BandwithConf"] as? String == "20MHz")
        #expect(encodedJson["Mode"] as? String == "11ng")
    }

    @Test("BandwidthConf enum cases")
    func testBandwidthConfEnum() {
        // Test creation from raw values (case-insensitive)
        // Note: init never returns nil, uses .unknown for unrecognized values
        #expect(AccessPoint.BandwidthConf(rawValue: "Auto")! == .auto)
        #expect(AccessPoint.BandwidthConf(rawValue: "auto")! == .auto)
        #expect(AccessPoint.BandwidthConf(rawValue: "AUTO")! == .auto)

        #expect(AccessPoint.BandwidthConf(rawValue: "20MHz")! == ._20mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "20mhz")! == ._20mhz)

        #expect(AccessPoint.BandwidthConf(rawValue: "40MHz")! == ._40mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "40mhz")! == ._40mhz)

        #expect(AccessPoint.BandwidthConf(rawValue: "80MHz")! == ._80mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "80mhz")! == ._80mhz)

        #expect(AccessPoint.BandwidthConf(rawValue: "160MHz")! == ._160mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "160mhz")! == ._160mhz)

        #expect(AccessPoint.BandwidthConf(rawValue: "20/40MHz")! == ._20_40mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "20/40mhz")! == ._20_40mhz)

        #expect(AccessPoint.BandwidthConf(rawValue: "80/40/20MHz")! == ._80_40_20mhz)
        #expect(AccessPoint.BandwidthConf(rawValue: "80/40/20mhz")! == ._80_40_20mhz)

        // Test unknown values
        let unknown = AccessPoint.BandwidthConf(rawValue: "UnknownValue")!
        if case .unknown(let value) = unknown {
            #expect(value == "UnknownValue")
        } else {
            #expect(Bool(false), "Should create unknown case")
        }

        // Test raw values (proper capitalization)
        #expect(AccessPoint.BandwidthConf.auto.rawValue == "Auto")
        #expect(AccessPoint.BandwidthConf._20mhz.rawValue == "20MHz")
        #expect(AccessPoint.BandwidthConf._40mhz.rawValue == "40MHz")
        #expect(AccessPoint.BandwidthConf._80mhz.rawValue == "80MHz")
        #expect(AccessPoint.BandwidthConf._160mhz.rawValue == "160MHz")
        #expect(AccessPoint.BandwidthConf._20_40mhz.rawValue == "20/40MHz")
        #expect(AccessPoint.BandwidthConf._80_40_20mhz.rawValue == "80/40/20MHz")

        // Test unknown case raw value
        let unknownCase = AccessPoint.BandwidthConf.unknown("CustomValue")
        #expect(unknownCase.rawValue == "CustomValue")
    }

    @Test("BandwidthConf decoding with various formats")
    func testBandwidthConfDecoding() throws {
        // Test decoding with lowercase
        let json1 = """
            {
                "idx": "TEST",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Test",
                "Password": "pass",
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "40mhz",
                "Bandwith": "40MHz",
                "SchedulingAllowed": true
            }
            """
        let data1 = json1.data(using: .utf8)!
        let ap1 = try JSONDecoder().decode(AccessPoint.self, from: data1)
        #expect(ap1.bandwidthConf == ._40mhz)

        // Test decoding with uppercase
        let json2 = """
            {
                "idx": "TEST",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Test",
                "Password": "pass",
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "AUTO",
                "Bandwith": "Auto",
                "SchedulingAllowed": true
            }
            """
        let data2 = json2.data(using: .utf8)!
        let ap2 = try JSONDecoder().decode(AccessPoint.self, from: data2)
        #expect(ap2.bandwidthConf == .auto)

        // Test decoding with unknown value
        let json3 = """
            {
                "idx": "TEST",
                "BSSID": "8C:19:B5:F8:ED:A7",
                "Type": "Home",
                "Manner": "Combined",
                "Status": "Up",
                "SSID": "Test",
                "Password": "pass",
                "ChannelConf": "Auto",
                "Channel": 6,
                "BandwithConf": "FutureValue",
                "Bandwith": "FutureValue",
                "SchedulingAllowed": true
            }
            """
        let data3 = json3.data(using: .utf8)!
        let ap3 = try JSONDecoder().decode(AccessPoint.self, from: data3)
        if case .unknown(let value) = ap3.bandwidthConf {
            #expect(value == "FutureValue")
        } else {
            #expect(Bool(false), "Should decode as unknown")
        }
    }

    @Test("BandwidthConf encoding preserves proper format")
    func testBandwidthConfEncoding() throws {
        let accessPoint = AccessPoint(
            bssid: "8C:19:B5:F8:ED:A7",
            type: .home,
            manner: .combined,
            status: .up,
            ssid: "Test",
            password: "pass",
            channelConf: .auto,
            channel: 6,
            bandwidthConf: ._80_40_20mhz,
            bandwidth: "80/40/20MHz",
            schedulingAllowed: true
        )

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(accessPoint)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // Verify proper capitalization is maintained
        #expect(encodedJson["BandwithConf"] as? String == "80/40/20MHz")
    }

    @Test("BandwidthConf all bandwidth options")
    func testAllBandwidthOptions() throws {
        let bandwidths: [(AccessPoint.BandwidthConf, String)] = [
            (.auto, "Auto"),
            (._20mhz, "20MHz"),
            (._40mhz, "40MHz"),
            (._80mhz, "80MHz"),
            (._160mhz, "160MHz"),
            (._20_40mhz, "20/40MHz"),
            (._80_40_20mhz, "80/40/20MHz"),
        ]

        for (bandwidth, expectedRawValue) in bandwidths {
            let accessPoint = AccessPoint(
                bssid: "8C:19:B5:F8:ED:A7",
                type: .home,
                manner: .combined,
                status: .up,
                ssid: "Test",
                password: "pass",
                channelConf: .auto,
                channel: 6,
                bandwidthConf: bandwidth,
                bandwidth: expectedRawValue,
                schedulingAllowed: true
            )

            // Encode and verify
            let encodedData = try JSONEncoder().encode(accessPoint)
            let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]
            #expect(encodedJson["BandwithConf"] as? String == expectedRawValue)

            // Decode and verify round-trip
            let decodedAccessPoint = try JSONDecoder().decode(AccessPoint.self, from: encodedData)
            #expect(decodedAccessPoint.bandwidthConf == bandwidth)
        }
    }

    @Test("AccessPoint with minimal properties")
    func AccessPointMinimalProperties() throws {
        // Create a AccessPoint request with only required properties
        let request = TestHelpers.createTestAccessPoint().copy(
            status: .up,
            ssid: "Minimal-Network",
            password: "minimalPassword",
            channelConf: .auto,
            bandwidthConf: ._20mhz,
            mode: "11ng"
        )

        // Test basic properties
        #expect(request.status == .up)
        #expect(request.ssid == "Minimal-Network")
        #expect(request.password == "minimalPassword")
        #expect(request.wmmEnable == nil)
        #expect(request.uapsdEnable == nil)
        #expect(request.apBridgeDisable == nil)
        #expect(request.channelConf == .auto)
        #expect(request.bandwidthConf == ._20mhz)
        #expect(request.mode == "11ng")

        // Test encoding
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(request)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["Status"] as? String == "Up")
        #expect(encodedJson["SSID"] as? String == "Minimal-Network")
        #expect(encodedJson["Password"] as? String == "minimalPassword")
        #expect(encodedJson["ChannelConf"] as? String == "Auto")
        #expect(encodedJson["BandwithConf"] as? String == "20MHz")
        #expect(encodedJson["Mode"] as? String == "11ng")
        #expect(!encodedJson.keys.contains("WMMEnable"))
        #expect(!encodedJson.keys.contains("UAPSDEnable"))
        #expect(!encodedJson.keys.contains("APBridgeDisable"))
    }
}
