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
        #expect(AccessPoint.AccessPointType(rawValue: "Home") == .home)
        #expect(AccessPoint.AccessPointType(rawValue: "Guest") == .guest)
        #expect(AccessPoint.AccessPointType(rawValue: "Unknown") == nil)

        // Test raw values
        #expect(AccessPoint.AccessPointType.home.rawValue == "Home")
        #expect(AccessPoint.AccessPointType.guest.rawValue == "Guest")
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
