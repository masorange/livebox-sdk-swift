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
        let info = try JSONDecoder().decode(GeneralInfo.self, from: jsonData)

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
        #expect(info.manufacturerURL == nil)
        #expect(info.country == nil)
        #expect(info.numberOfReboots == nil)
        #expect(info.upgradeOccurred == nil)
        #expect(info.restoreOccurred == nil)
    }

    @Test("Decoding GeneralInfo from ZTE JSON")
    func testDecodingZteJSON() throws {
        let json = """
            {
                "ApiVersion": "2.2.7",
                "Description": "HomeGateWay",
                "DeviceLog": "/var/userlog.txt",
                "FirstUseDate": "0001-01-01T00:00:00Z",
                "HardwareVersion": "ZTEGLBFIB6S1.0.0",
                "ManuFacturer": "ZTE",
                "ManufacturerOUI": "F4E84F",
                "ManufacturerURL": "",
                "ModelName": "ZTEGFIBRA6S",
                "ModemFirmwareVersion": "",
                "ProductClass": "ZTEGFIBRA6S",
                "ProvisioningCode": "",
                "RouterImage": "http://192.168.1.1/img/top.png",
                "RouterName": "Livebox",
                "SerialNumber": "ZTEGD2FBA2F2",
                "SoftwareVersion": "ZTEFIBRA6S-sp-P01N05",
                "SpecVersion": "1.0",
                "UpTime": "2674"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let info = try JSONDecoder().decode(GeneralInfo.self, from: jsonData)

        // Test mandatory fields - alternative key "ManuFacturer" should work
        #expect(info.manufacturer == "ZTE")
        #expect(info.modelName == "ZTEGFIBRA6S")
        #expect(info.productClass == "ZTEGFIBRA6S")
        #expect(info.serialNumber == "ZTEGD2FBA2F2")
        #expect(info.hardwareVersion == "ZTEGLBFIB6S1.0.0")
        #expect(info.softwareVersion == "ZTEFIBRA6S-sp-P01N05")

        // Test UpTime as string to int conversion
        #expect(info.upTime == 2674)
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

        let data = try JSONEncoder().encode(info)
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
        let info = try JSONDecoder().decode(GeneralInfo.self, from: jsonData)

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

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(GeneralInfo.self, from: jsonData)
        }
    }

    @Test("Encoding uses standard 'Manufacturer' key")
    func testEncodingUsesStandardKey() throws {
        let info = GeneralInfo(
            manufacturer: "TestManufacturer",
            modelName: "TestModel",
            productClass: "TestClass",
            serialNumber: "TEST123",
            hardwareVersion: "1.0.0",
            softwareVersion: "1.0.0"
        )

        let data = try JSONEncoder().encode(info)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // Should encode as "Manufacturer" (the standard key)
        #expect(json["Manufacturer"] as? String == "TestManufacturer")
        // Should not have other variants
        #expect(json["ManuFacturer"] == nil)
        #expect(json["manufacturer"] == nil)
    }

    @Test("Alternative manufacturer key works (ManuFacturer)")
    func testAlternativeManufacturerKey() throws {
        let json = """
            {
                "ManuFacturer": "ZTE",
                "ModelName": "TestModel",
                "ProductClass": "Livebox",
                "SerialNumber": "TEST123",
                "HardwareVersion": "1.0.0",
                "SoftwareVersion": "1.0.0",
                "UpTime": 0
            }
            """

        let jsonData = json.data(using: .utf8)!
        let info = try JSONDecoder().decode(GeneralInfo.self, from: jsonData)

        #expect(info.manufacturer == "ZTE")
        #expect(info.modelName == "TestModel")
    }

    @Test("Encoding to data works")
    func testEncodeToData() throws {
        let info = GeneralInfo(
            manufacturer: "TestBrand",
            modelName: "TestModel",
            productClass: "TestClass",
            serialNumber: "SN12345",
            hardwareVersion: "HW1.0",
            softwareVersion: "SW1.0"
        )

        let data = try JSONEncoder().encode(info)

        // Verify we can decode it back
        let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #expect(decoded != nil)
        #expect(decoded?["Manufacturer"] as? String == "TestBrand")
        #expect(decoded?["ModelName"] as? String == "TestModel")
    }

    @Test("FlexibleInt handles string to int conversion for UpTime")
    func testStringToIntConversion() throws {
        let json = """
            {
                "Manufacturer": "TestBrand",
                "ModelName": "TestModel",
                "ProductClass": "TestClass",
                "SerialNumber": "TEST123",
                "HardwareVersion": "1.0.0",
                "SoftwareVersion": "1.0.0",
                "UpTime": "98765"
            }
            """

        let jsonData = json.data(using: .utf8)!
        let info = try JSONDecoder().decode(GeneralInfo.self, from: jsonData)

        // String value should be converted to Int using @FlexibleInt
        #expect(info.upTime == 98765)
    }

}
