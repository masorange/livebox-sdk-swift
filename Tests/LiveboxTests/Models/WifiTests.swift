import Foundation
import Testing

@testable import Livebox

@Suite("Wifi Tests")
struct WifiTests {
    @Test("Decoding WiFi interface without Status")
    func testDecodingWithoutStatus() throws {
        let json = """
            {
                "Id": "24GHz",
                "Frequency": "2.4GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.id == "24GHz")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == ._2_4GHz)
        #expect(wifi.isWifiInterface)
    }

    @Test("Filtering WiFi interfaces from mixed array")
    func testFilteringWifiInterfaces() throws {
        let json = """
            [
                {
                    "WiFiStatusButton": true
                },
                {
                    "Id": "24GHz",
                    "Status": "Up",
                    "Frequency": "2.4GHz"
                },
                {
                    "Id": "5GHz",
                    "Status": "Down",
                    "Frequency": "5GHz"
                }
            ]
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifiArray = try decoder.decode([Wifi].self, from: jsonData)

        // Test the full array
        #expect(wifiArray.count == 3)

        // Test the filtered interfaces
        let interfaces = wifiArray.wifiInterfaces
        #expect(interfaces.count == 2)
        #expect(interfaces[0].id == "24GHz")
        #expect(interfaces[1].id == "5GHz")
    }

    @Test("Decoding WiFi interface with 2.4GHz frequency from JSON")
    func testDecoding24GHz() throws {
        let json = """
            {
                "Id": "24GHz",
                "Status": "Up",
                "Frequency": "2.4GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.id == "24GHz")
        #expect(wifi.status == .up)
        #expect(wifi.frequency == ._2_4GHz)
        #expect(wifi.isWifiInterface)
    }

    @Test("Decoding WiFi interface with 5GHz frequency from JSON")
    func testDecoding5GHz() throws {
        let json = """
            {
                "Id": "5GHz",
                "Status": "Up",
                "Frequency": "5GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.id == "5GHz")
        #expect(wifi.status == .up)
        #expect(wifi.frequency == ._5GHz)
        #expect(wifi.isWifiInterface)
    }

    @Test("Decoding WiFi status button as Bool true from JSON")
    func testDecodingStatusButtonBoolTrue() throws {
        let json = """
            {
                "WiFiStatusButton": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.wifiStatusButton == true)
        #expect(wifi.id == "")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == .unknown)
        #expect(!wifi.isWifiInterface)
    }

    @Test("Decoding WiFi status button as Bool false from JSON")
    func testDecodingStatusButtonBoolFalse() throws {
        let json = """
            {
                "WiFiStatusButton": false
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.wifiStatusButton == false)
        #expect(wifi.id == "")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == .unknown)
        #expect(!wifi.isWifiInterface)
    }

    @Test("Decoding WiFi status button as String 'true' from JSON")
    func testDecodingStatusButtonStringTrue() throws {
        let json = """
            {
                "WiFiStatusButton": "true"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.wifiStatusButton == true)
        #expect(wifi.id == "")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == .unknown)
        #expect(!wifi.isWifiInterface)
    }

    @Test("Decoding WiFi status button as String 'false' from JSON")
    func testDecodingStatusButtonStringFalse() throws {
        let json = """
            {
                "WiFiStatusButton": "false"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.wifiStatusButton == false)
        #expect(wifi.id == "")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == .unknown)
        #expect(!wifi.isWifiInterface)
    }

    @Test("Decoding WiFi status button as String with case variations")
    func testDecodingStatusButtonStringCaseInsensitive() throws {
        // Test uppercase "TRUE"
        let json1 = """
            {
                "WiFiStatusButton": "TRUE"
            }
            """
        let data1 = json1.data(using: .utf8)!
        let wifi1 = try JSONDecoder().decode(Wifi.self, from: data1)
        #expect(wifi1.wifiStatusButton == true)

        // Test mixed case "True"
        let json2 = """
            {
                "WiFiStatusButton": "True"
            }
            """
        let data2 = json2.data(using: .utf8)!
        let wifi2 = try JSONDecoder().decode(Wifi.self, from: data2)
        #expect(wifi2.wifiStatusButton == true)

        // Test uppercase "FALSE"
        let json3 = """
            {
                "WiFiStatusButton": "FALSE"
            }
            """
        let data3 = json3.data(using: .utf8)!
        let wifi3 = try JSONDecoder().decode(Wifi.self, from: data3)
        #expect(wifi3.wifiStatusButton == false)

        // Test mixed case "False"
        let json4 = """
            {
                "WiFiStatusButton": "False"
            }
            """
        let data4 = json4.data(using: .utf8)!
        let wifi4 = try JSONDecoder().decode(Wifi.self, from: data4)
        #expect(wifi4.wifiStatusButton == false)
    }

    @Test("Decoding WiFi status button as invalid String value")
    func testDecodingStatusButtonInvalidString() throws {
        let json = """
            {
                "WiFiStatusButton": "invalid"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        // Invalid string values should decode as false (not "true")
        #expect(wifi.wifiStatusButton == false)
        #expect(!wifi.isWifiInterface)
    }

    @Test("Decoding WiFi interface with Down status from JSON")
    func testDecodingDownStatus() throws {
        let json = """
            {
                "Id": "24GHz",
                "Status": "Down",
                "Frequency": "2.4GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.id == "24GHz")
        #expect(wifi.status == .down)
        #expect(wifi.frequency == ._2_4GHz)
        #expect(wifi.isWifiInterface)
    }

    @Test("Decoding WiFi interface with unknown status from JSON")
    func testDecodingUnknownStatus() throws {
        let json = """
            {
                "Id": "24GHz",
                "Status": "SomeOtherStatus",
                "Frequency": "2.4GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        #expect(wifi.id == "24GHz")
        #expect(wifi.status == .unknown)
        #expect(wifi.frequency == ._2_4GHz)
        #expect(wifi.isWifiInterface)
    }

    @Test("Wifi.Status initialization from raw values")
    func testStatusInitialization() {
        #expect(Wifi.Status(rawValue: "Up") == .up)
        #expect(Wifi.Status(rawValue: "up") == .up)
        #expect(Wifi.Status(rawValue: "UP") == .up)

        #expect(Wifi.Status(rawValue: "Down") == .down)
        #expect(Wifi.Status(rawValue: "down") == .down)
        #expect(Wifi.Status(rawValue: "DOWN") == .down)

        #expect(Wifi.Status(rawValue: "") == .unknown)
        #expect(Wifi.Status(rawValue: "Unknown") == .unknown)
        #expect(Wifi.Status(rawValue: "SomeOtherStatus") == .unknown)
    }

    @Test("Encoding WiFi interface to JSON")
    func testEncoding() throws {
        // Since Wifi model doesn't have a public initializer and uses private properties,
        // we'll decode from JSON first and then encode back
        let json = """
            {
                "Id": "24GHz",
                "Status": "Up",
                "Frequency": "2.4GHz"
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let wifi = try decoder.decode(Wifi.self, from: jsonData)

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(wifi)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        #expect(encodedJson["Id"] as? String == "24GHz")
        #expect(encodedJson["Status"] as? String == "Up")
        #expect(encodedJson["Frequency"] as? String == "2.4GHz")
        // WiFiStatusButton should not be encoded since it's nil
        #expect(encodedJson["WiFiStatusButton"] == nil)
    }

    @Test("Encoding WiFi status button encodes as Bool")
    func testEncodingStatusButton() throws {
        // Decode from String "true"
        let json = """
            {
                "WiFiStatusButton": "true"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let wifi = try JSONDecoder().decode(Wifi.self, from: jsonData)

        // Encode back - should encode as Bool, not String
        let encodedData = try JSONEncoder().encode(wifi)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData) as! [String: Any]

        // The encoded value should be a Bool true, not a String "true"
        #expect(encodedJson["WiFiStatusButton"] as? Bool == true)
    }

    @Test("Round-trip encoding preserves values from String input")
    func testRoundTripEncodingFromString() throws {
        // Start with String-based WiFiStatusButton
        let json = """
            {
                "WiFiStatusButton": "false"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let wifi1 = try JSONDecoder().decode(Wifi.self, from: jsonData)

        // Encode and decode again
        let encodedData = try JSONEncoder().encode(wifi1)
        let wifi2 = try JSONDecoder().decode(Wifi.self, from: encodedData)

        // Values should be preserved
        #expect(wifi1.wifiStatusButton == wifi2.wifiStatusButton)
        #expect(wifi2.wifiStatusButton == false)
    }
}
