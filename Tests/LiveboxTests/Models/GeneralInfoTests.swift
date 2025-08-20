import Foundation
import Testing

@testable import Livebox

@Suite("GeneralInfo Tests")
struct GeneralInfoTests {
    @Test("Decoding GeneralInfo from JSON")
    func testDecoding() throws {
        let json = """
            {
                "Manufacturer": "Sagemcom",
                "ManufacturerOUI": "40F201",
                "ModelName": "SagemcomFast5360",
                "Description": "SagemcomFast5360 Sagemcom fr",
                "ProductClass": "Livebox",
                "SerialNumber": "LK15050DP990080",
                "HardwareVersion": "SG_LB4_1.0.0",
                "SoftwareVersion": "SG40_sip-fr-2.3.4.1",
                "RescueVersion": "SG40_sip-fr-2.3.2.1",
                "ApiVersion": "2.2.17",
                "RouterImage": "http://liveboxfibra/images/livebox.png",
                "RouterName": "Livebox Fibra",
                "UpTime": 76203,
                "ResetOccurred": true
            }
            """

        let jsonData = json.data(using: .utf8)!

        let decoder = JSONDecoder()
        let info = try decoder.decode(GeneralInfo.self, from: jsonData)

        // Test mandatory fields
        #expect(info.manufacturer == "Sagemcom")
        #expect(info.modelName == "SagemcomFast5360")
        #expect(info.productClass == "Livebox")
        #expect(info.serialNumber == "LK15050DP990080")
        #expect(info.hardwareVersion == "SG_LB4_1.0.0")
        #expect(info.softwareVersion == "SG40_sip-fr-2.3.4.1")

        // Test optional fields that are present
        #expect(info.manufacturerOUI == "40F201")
        #expect(info.description == "SagemcomFast5360 Sagemcom fr")
        #expect(info.rescueVersion == "SG40_sip-fr-2.3.2.1")
        #expect(info.upTime == 76203)
        #expect(info.resetOccurred == true)
        #expect(info.apiVersion == "2.2.17")
        #expect(info.routerImage == "http://liveboxfibra/images/livebox.png")
        #expect(info.routerName == "Livebox Fibra")

        // Test nil fields
        #expect(info.modemFirmwareVersion == nil)
        #expect(info.enabledOptions == nil)
        #expect(info.additionalHardwareVersion == nil)
        #expect(info.additionalSoftwareVersion == nil)
        #expect(info.specVersion == nil)
        #expect(info.provisioningCode == nil)
        #expect(info.firstUseDate == nil)
        #expect(info.deviceLog == nil)
        #expect(info.vendorConfigFileNumberOfEntries == nil)
        #expect(info.manufacturerURL == nil)
        #expect(info.country == nil)
        #expect(info.numberOfReboots == nil)
        #expect(info.upgradeOccurred == nil)
        #expect(info.restoreOccurred == nil)
    }

    @Test("Encoding GeneralInfo to JSON")
    func testEncoding() throws {
        let info = GeneralInfo(
            manufacturer: "Sagemcom",
            manufacturerOUI: "40F201",
            modelName: "SagemcomFast5360",
            description: "SagemcomFast5360 Sagemcom fr",
            productClass: "Livebox",
            serialNumber: "LK15050DP990080",
            hardwareVersion: "SG_LB4_1.0.0",
            softwareVersion: "SG40_sip-fr-2.3.4.1",
            rescueVersion: "SG40_sip-fr-2.3.2.1",
            modemFirmwareVersion: nil,
            enabledOptions: nil,
            additionalHardwareVersion: nil,
            additionalSoftwareVersion: "g0-r-sip-fr",
            specVersion: nil,
            provisioningCode: nil,
            upTime: 76203,
            firstUseDate: nil,
            deviceLog: nil,
            vendorConfigFileNumberOfEntries: nil,
            manufacturerURL: nil,
            country: nil,
            numberOfReboots: 1,
            upgradeOccurred: false,
            resetOccurred: true,
            restoreOccurred: false,
            apiVersion: "2.2.17",
            routerImage: "http://liveboxfibra/images/livebox.png",
            routerName: "Livebox Fibra"
        )
        let encoder = JSONEncoder()

        let data = try encoder.encode(info)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Test mandatory fields
        #expect(json["Manufacturer"] as? String == "Sagemcom")
        #expect(json["ModelName"] as? String == "SagemcomFast5360")
        #expect(json["ProductClass"] as? String == "Livebox")
        #expect(json["SerialNumber"] as? String == "LK15050DP990080")
        #expect(json["HardwareVersion"] as? String == "SG_LB4_1.0.0")
        #expect(json["SoftwareVersion"] as? String == "SG40_sip-fr-2.3.4.1")

        // Test optional fields that are present
        #expect(json["ManufacturerOUI"] as? String == "40F201")
        #expect(json["Description"] as? String == "SagemcomFast5360 Sagemcom fr")
        #expect(json["RescueVersion"] as? String == "SG40_sip-fr-2.3.2.1")
        #expect(json["AdditionalSoftwareVersion"] as? String == "g0-r-sip-fr")
        #expect(json["UpTime"] as? Int == 76203)
        #expect(json["NumberOfReboots"] as? Int == 1)
        #expect(json["UpgradeOccurred"] as? Bool == false)
        #expect(json["ResetOccurred"] as? Bool == true)
        #expect(json["RestoreOccurred"] as? Bool == false)
        #expect(json["ApiVersion"] as? String == "2.2.17")
        #expect(json["RouterImage"] as? String == "http://liveboxfibra/images/livebox.png")
        #expect(json["RouterName"] as? String == "Livebox Fibra")

        // Test that nil fields are not present in JSON
        #expect(json["ModemFirmwareVersion"] == nil)
        #expect(json["EnabledOptions"] == nil)
        #expect(json["AdditionalHardwareVersion"] == nil)
        #expect(json["SpecVersion"] == nil)
        #expect(json["ProvisioningCode"] == nil)
        #expect(json["FirstUseDate"] == nil)
        #expect(json["DeviceLog"] == nil)
        #expect(json["VendorConfigFileNumberOfEntries"] == nil)
        #expect(json["ManufacturerURL"] == nil)
        #expect(json["Country"] == nil)
    }

    @Test("Decoding GeneralInfo with minimal JSON")
    func testDecodingMinimalJSON() throws {
        let json = """
            {
                "Manufacturer": "TestManufacturer",
                "ModelName": "TestModel",
                "ProductClass": "TestClass",
                "SerialNumber": "TEST123",
                "HardwareVersion": "1.0.0",
                "SoftwareVersion": "1.0.0"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let info = try decoder.decode(GeneralInfo.self, from: jsonData)

        // Test mandatory fields
        #expect(info.manufacturer == "TestManufacturer")
        #expect(info.modelName == "TestModel")
        #expect(info.productClass == "TestClass")
        #expect(info.serialNumber == "TEST123")
        #expect(info.hardwareVersion == "1.0.0")
        #expect(info.softwareVersion == "1.0.0")

        // All optional fields should be nil
        #expect(info.manufacturerOUI == nil)
        #expect(info.description == nil)
        #expect(info.rescueVersion == nil)
        #expect(info.upTime == nil)
        #expect(info.resetOccurred == nil)
        #expect(info.apiVersion == nil)
        #expect(info.routerImage == nil)
        #expect(info.routerName == nil)
    }

    @Test("Decoding fails with missing mandatory fields")
    func testDecodingFailsWithMissingFields() throws {
        let json = """
            {
                "Manufacturer": "TestManufacturer",
                "ModelName": "TestModel"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            try decoder.decode(GeneralInfo.self, from: jsonData)
        }
    }
}
