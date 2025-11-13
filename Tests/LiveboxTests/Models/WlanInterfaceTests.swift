import Foundation
import Testing

@testable import Livebox

@Suite("WlanInterface Tests")
struct WlanInterfaceTests {
    @Test("Decoding WlanInterface with AccessPoints from JSON")
    func testDecodingWithAccessPoints() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "LastChangeTime": 0,
                "LastChange": 0,
                "AccessPoints": [{
                    "Idx": "8C19B5F8EDA7",
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "RemainingDuration": -1,
                    "SSID": "Livebox6-EDA9"
                }, {
                    "Idx": "9219B5F8EDA0",
                    "BSSID": "92:19:B5:F8:ED:A0",
                    "Status": "Down",
                    "RemainingDuration": -1,
                    "SSID": "Livebox6-EDA9-5G"
                }, {
                    "Idx": "9219B5F8EDA2",
                    "BSSID": "92:19:B5:F8:ED:A2",
                    "Status": "Up",
                    "RemainingDuration": -1,
                    "SSID": "Invitado-EDA9"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        // Test WlanInterface properties
        #expect(wlanInterface.id == "5GHz")
        #expect(wlanInterface.status == .up)
        #expect(wlanInterface.frequency == "5GHz")
        #expect(wlanInterface.lastChangeTime == 0)
        #expect(wlanInterface.lastChange == 0)

        // Test AccessPoints array
        #expect(wlanInterface.accessPoints.count == 3)

        // Test first AccessPoint
        let firstAP = wlanInterface.accessPoints[0]
        #expect(firstAP.idx == "8C19B5F8EDA7")
        #expect(firstAP.bssid == "8C:19:B5:F8:ED:A7")
        #expect(firstAP.status == .up)
        #expect(firstAP.remainingDuration == -1)
        #expect(firstAP.ssid == "Livebox6-EDA9")

        // Test second AccessPoint
        let secondAP = wlanInterface.accessPoints[1]
        #expect(secondAP.idx == "9219B5F8EDA0")
        #expect(secondAP.bssid == "92:19:B5:F8:ED:A0")
        #expect(secondAP.status == .down)
        #expect(secondAP.remainingDuration == -1)
        #expect(secondAP.ssid == "Livebox6-EDA9-5G")

        // Test third AccessPoint
        let thirdAP = wlanInterface.accessPoints[2]
        #expect(thirdAP.idx == "9219B5F8EDA2")
        #expect(thirdAP.bssid == "92:19:B5:F8:ED:A2")
        #expect(thirdAP.status == .up)
        #expect(thirdAP.remainingDuration == -1)
        #expect(thirdAP.ssid == "Invitado-EDA9")
    }

    @Test("Decoding WlanInterface without optional fields from JSON")
    func testDecodingWithoutOptionalFields() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": []
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.id == "5GHz")
        #expect(wlanInterface.status == .up)
        #expect(wlanInterface.frequency == "5GHz")
        #expect(wlanInterface.lastChangeTime == nil)
        #expect(wlanInterface.lastChange == nil)
        #expect(wlanInterface.accessPoints.isEmpty)
    }

    @Test("Decoding WlanInterface with Down status from JSON")
    func testDecodingWithDownStatus() throws {
        let json = """
            {
                "Id": "24GHz",
                "Status": "Down",
                "Frequency": "2.4GHz",
                "AccessPoints": []
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.id == "24GHz")
        #expect(wlanInterface.status == .down)
        #expect(wlanInterface.frequency == "2.4GHz")
        #expect(wlanInterface.accessPoints.isEmpty)
    }

    @Test("Decoding WlanInterface with unknown status from JSON")
    func testDecodingWithUnknownStatus() throws {
        let json = """
            {
                "Id": "24GHz",
                "Status": "SomeOtherStatus",
                "Frequency": "2.4GHz",
                "AccessPoints": []
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.id == "24GHz")
        #expect(wlanInterface.status == .unknown)
        #expect(wlanInterface.frequency == "2.4GHz")
        #expect(wlanInterface.accessPoints.isEmpty)
    }

    @Test("Decoding ShortAccessPoint with missing remainingDuration")
    func testDecodingShortAccessPointWithoutRemainingDuration() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": [{
                    "Idx": "8C19B5F8EDA7",
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "SSID": "Livebox6-EDA9"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.accessPoints.count == 1)
        let accessPoint = wlanInterface.accessPoints[0]
        #expect(accessPoint.idx == "8C19B5F8EDA7")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.status == .up)
        #expect(accessPoint.remainingDuration == nil)
        #expect(accessPoint.ssid == "Livebox6-EDA9")
    }

    @Test("WlanInterface.Status initialization from raw values")
    func testStatusInitialization() {
        #expect(WlanInterface.Status(rawValue: "Up") == .up)
        #expect(WlanInterface.Status(rawValue: "up") == .up)
        #expect(WlanInterface.Status(rawValue: "UP") == .up)

        #expect(WlanInterface.Status(rawValue: "Down") == .down)
        #expect(WlanInterface.Status(rawValue: "down") == .down)
        #expect(WlanInterface.Status(rawValue: "DOWN") == .down)

        #expect(WlanInterface.Status(rawValue: "") == .unknown)
        #expect(WlanInterface.Status(rawValue: "Unknown") == .unknown)
        #expect(WlanInterface.Status(rawValue: "SomeOtherStatus") == .unknown)
    }

    @Test("Decoding ShortAccessPoint without Idx field derives from BSSID")
    func testDecodingShortAccessPointWithoutIdx() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": [{
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "SSID": "Livebox6-EDA9"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.accessPoints.count == 1)
        let accessPoint = wlanInterface.accessPoints[0]
        // Idx should be derived from BSSID by removing colons
        #expect(accessPoint.idx == "8C19B5F8EDA7")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.status == .up)
        #expect(accessPoint.ssid == "Livebox6-EDA9")
    }

    @Test("Decoding ShortAccessPoint with Idx field uses provided value")
    func testDecodingShortAccessPointWithIdx() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": [{
                    "Idx": "CustomIndex123",
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "SSID": "Livebox6-EDA9"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.accessPoints.count == 1)
        let accessPoint = wlanInterface.accessPoints[0]
        // Idx should use the provided value, not derive from BSSID
        #expect(accessPoint.idx == "CustomIndex123")
        #expect(accessPoint.bssid == "8C:19:B5:F8:ED:A7")
        #expect(accessPoint.status == .up)
        #expect(accessPoint.ssid == "Livebox6-EDA9")
    }

    @Test("Decoding multiple ShortAccessPoints with mixed Idx scenarios")
    func testDecodingMixedIdxScenarios() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": [{
                    "Idx": "ProvidedIndex",
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "SSID": "AP-With-Idx"
                }, {
                    "BSSID": "92:19:B5:F8:ED:A0",
                    "Status": "Down",
                    "SSID": "AP-Without-Idx"
                }, {
                    "Idx": "AnotherCustomIdx",
                    "BSSID": "AA:BB:CC:DD:EE:FF",
                    "Status": "Up",
                    "SSID": "AP-Custom-Idx"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        #expect(wlanInterface.accessPoints.count == 3)

        // First AP: has Idx provided
        let firstAP = wlanInterface.accessPoints[0]
        #expect(firstAP.idx == "ProvidedIndex")
        #expect(firstAP.bssid == "8C:19:B5:F8:ED:A7")

        // Second AP: Idx missing, should be derived from BSSID
        let secondAP = wlanInterface.accessPoints[1]
        #expect(secondAP.idx == "9219B5F8EDA0")
        #expect(secondAP.bssid == "92:19:B5:F8:ED:A0")

        // Third AP: has Idx provided
        let thirdAP = wlanInterface.accessPoints[2]
        #expect(thirdAP.idx == "AnotherCustomIdx")
        #expect(thirdAP.bssid == "AA:BB:CC:DD:EE:FF")
    }

    @Test("Encoding WlanInterface to JSON")
    func testEncoding() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "LastChangeTime": 0,
                "LastChange": 0,
                "AccessPoints": [{
                    "Idx": "8C19B5F8EDA7",
                    "BSSID": "8C:19:B5:F8:ED:A7",
                    "Status": "Up",
                    "RemainingDuration": -1,
                    "SSID": "Livebox6-EDA9"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wlanInterface = try decoder.decode(WlanInterface.self, from: jsonData)

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(wlanInterface)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // Test main properties
        #expect(encodedJson["Id"] as? String == "5GHz")
        #expect(encodedJson["Status"] as? String == "Up")
        #expect(encodedJson["Frequency"] as? String == "5GHz")
        #expect(encodedJson["LastChangeTime"] as? Int == 0)
        #expect(encodedJson["LastChange"] as? Int == 0)

        // Test AccessPoints array
        let accessPoints = encodedJson["AccessPoints"] as? [[String: Any]]
        #expect(accessPoints?.count == 1)

        if let firstAP = accessPoints?.first {
            #expect(firstAP["Idx"] as? String == "8C19B5F8EDA7")
            #expect(firstAP["BSSID"] as? String == "8C:19:B5:F8:ED:A7")
            #expect(firstAP["Status"] as? String == "Up")
            #expect(firstAP["RemainingDuration"] as? Int == -1)
            #expect(firstAP["SSID"] as? String == "Livebox6-EDA9")
        }
    }

    @Test("Encoding ShortAccessPoint preserves derived Idx")
    func testEncodingShortAccessPointWithDerivedIdx() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz",
                "AccessPoints": [{
                    "BSSID": "AA:BB:CC:DD:EE:FF",
                    "Status": "Up",
                    "SSID": "TestNetwork"
                }]
            }
            """

        let jsonData = json.data(using: .utf8)!
        let wlanInterface = try JSONDecoder().decode(WlanInterface.self, from: jsonData)

        // Encode back to JSON
        let encodedData = try JSONEncoder().encode(wlanInterface)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // Check that the derived Idx is present in encoded JSON
        let accessPoints = encodedJson["AccessPoints"] as? [[String: Any]]
        #expect(accessPoints?.count == 1)

        if let firstAP = accessPoints?.first {
            // The derived Idx (BSSID without colons) should be encoded
            #expect(firstAP["Idx"] as? String == "AABBCCDDEEFF")
            #expect(firstAP["BSSID"] as? String == "AA:BB:CC:DD:EE:FF")
            #expect(firstAP["SSID"] as? String == "TestNetwork")
        }
    }
}
