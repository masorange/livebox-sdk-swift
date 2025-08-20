import Foundation
import Testing

@testable import Livebox

@Suite("Capabilities Tests")
struct CapabilitiesTests {

    @Test("Parse capabilities JSON")
    func testParseCapabilities() throws {
        // Arrange
        let jsonString = """
            {
              "Features": [
                {
                  "Id": "GeneralInfo",
                  "Uri": "/API/GeneralInfo",
                  "Ops": ["R"]
                },
                {
                  "Id": "Reboot",
                  "Uri": "/API/GeneralInfo/Reboot",
                  "Ops": ["I"]
                },
                {
                  "Id": "WlanInterface",
                  "Uri": "/API/LAN/WIFI/{wlan_ifc}",
                  "Ops": ["R", "W"]
                }
              ]
            }
            """

        let jsonData = jsonString.data(using: .utf8)!

        // Act
        let decoder = JSONDecoder()
        let capabilities = try decoder.decode(Capabilities.self, from: jsonData)

        // Assert
        #expect(capabilities.features.count == 3)

        // Check first feature
        let generalInfo = capabilities.features[0]
        #expect(generalInfo.id == "GeneralInfo")
        #expect(generalInfo.uri == "/API/GeneralInfo")
        #expect(generalInfo.ops.count == 1)
        #expect(generalInfo.ops.first == .read)

        // Check second feature
        let reboot = capabilities.features[1]
        #expect(reboot.id == "Reboot")
        #expect(reboot.uri == "/API/GeneralInfo/Reboot")
        #expect(reboot.ops.count == 1)
        #expect(reboot.ops.first == .invoke)

        // Check feature with path variables
        let wlanInterface = capabilities.features[2]
        #expect(wlanInterface.id == "WlanInterface")
        #expect(wlanInterface.uri == "/API/LAN/WIFI/{wlan_ifc}")
        #expect(wlanInterface.ops.count == 2)
        #expect(wlanInterface.ops.contains(.read))
        #expect(wlanInterface.ops.contains(.write))
    }

    @Test("Get path with variables")
    func testGetPathWithVariables() {
        // Arrange
        let feature = Capabilities.Feature(
            id: "WlanInterface",
            uri: "/API/LAN/WIFI/{wlan_ifc}/{wlan_ap}",
            ops: [.read, .write])

        // Act
        let path = feature.getPath(pathVariables: ["wlan_ifc": "2.4GHz", "wlan_ap": "AP1"])

        // Assert
        #expect(path == "/API/LAN/WIFI/2.4GHz/AP1")
    }

    @Test("Get path variable names")
    func testGetPathVariableNames() {
        // Arrange
        let feature = Capabilities.Feature(
            id: "WlanInterface",
            uri: "/API/LAN/WIFI/{wlan_ifc}/{wlan_ap}",
            ops: [.read, .write])

        // Act
        let variableNames = feature.getPathVariableNames()

        // Assert
        #expect(variableNames.count == 2)
        #expect(variableNames[0] == "wlan_ifc")
        #expect(variableNames[1] == "wlan_ap")
    }

    @Test("Feature supports operation")
    func testSupportsOperation() {
        // Arrange
        let feature = Capabilities.Feature(
            id: "WlanInterface",
            uri: "/API/LAN/WIFI/{wlan_ifc}",
            ops: [.read, .write])

        // Act & Assert
        #expect(feature.supports(operation: .read))
        #expect(feature.supports(operation: .write))
        #expect(!feature.supports(operation: .invoke))
        #expect(!feature.supports(operation: .add))
        #expect(!feature.supports(operation: .delete))
        #expect(!feature.supports(operation: .query))
    }
}
