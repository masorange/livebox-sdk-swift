import Foundation

/// Model representing the general information of a router
public struct GeneralInfo: Codable {
    /// Manufacturer of the router
    public let manufacturer: String

    /// Manufacturer OUI (Organization Unique Identifier)
    public let manufacturerOUI: String?

    /// Model name of the router
    public let modelName: String

    /// Description of the router
    public let description: String?

    /// Product class of the router
    public let productClass: String

    /// Serial number of the router
    public let serialNumber: String

    /// Hardware version of the router
    public let hardwareVersion: String

    /// Software version of the router
    public let softwareVersion: String

    /// Rescue version of the router
    public let rescueVersion: String?

    /// Modem firmware version
    public let modemFirmwareVersion: String?

    /// Enabled options
    public let enabledOptions: String?

    /// Additional hardware version
    public let additionalHardwareVersion: String?

    /// Additional software version
    public let additionalSoftwareVersion: String?

    /// Spec version
    public let specVersion: String?

    /// Provisioning code
    public let provisioningCode: String?

    /// Uptime in seconds. Uses @FlexibleInt to support both Int and String values from different routers (e.g., ZTE routers may send this as a string)
    @FlexibleInt public var upTime: Int?

    /// First use date
    public let firstUseDate: String?

    /// Device log
    public let deviceLog: String?

    /// Manufacturer URL
    public let manufacturerURL: String?

    /// Country
    public let country: String?

    /// Number of reboots
    public let numberOfReboots: Int?

    /// Whether an upgrade occurred
    public let upgradeOccurred: Bool?

    /// Whether a reset occurred
    public let resetOccurred: Bool?

    /// Whether a restore occurred
    public let restoreOccurred: Bool?

    /// API version (mandatory since v2.2.7)
    public let apiVersion: String?

    /// Router image URL (mandatory since v2.2.7)
    public let routerImage: String?

    /// Router name (mandatory since v2.2.7)
    public let routerName: String?

    public init(
        manufacturer: String,
        manufacturerOUI: String? = nil,
        modelName: String,
        description: String? = nil,
        productClass: String,
        serialNumber: String,
        hardwareVersion: String,
        softwareVersion: String,
        rescueVersion: String? = nil,
        modemFirmwareVersion: String? = nil,
        enabledOptions: String? = nil,
        additionalHardwareVersion: String? = nil,
        additionalSoftwareVersion: String? = nil,
        specVersion: String? = nil,
        provisioningCode: String? = nil,
        upTime: Int? = nil,
        firstUseDate: String? = nil,
        deviceLog: String? = nil,
        manufacturerURL: String? = nil,
        country: String? = nil,
        numberOfReboots: Int? = nil,
        upgradeOccurred: Bool? = nil,
        resetOccurred: Bool? = nil,
        restoreOccurred: Bool? = nil,
        apiVersion: String? = nil,
        routerImage: String? = nil,
        routerName: String? = nil
    ) {
        self.manufacturer = manufacturer
        self.manufacturerOUI = manufacturerOUI
        self.modelName = modelName
        self.description = description
        self.productClass = productClass
        self.serialNumber = serialNumber
        self.hardwareVersion = hardwareVersion
        self.softwareVersion = softwareVersion
        self.rescueVersion = rescueVersion
        self.modemFirmwareVersion = modemFirmwareVersion
        self.enabledOptions = enabledOptions
        self.additionalHardwareVersion = additionalHardwareVersion
        self.additionalSoftwareVersion = additionalSoftwareVersion
        self.specVersion = specVersion
        self.provisioningCode = provisioningCode
        self._upTime = FlexibleInt(wrappedValue: upTime)
        self.firstUseDate = firstUseDate
        self.deviceLog = deviceLog
        self.manufacturerURL = manufacturerURL
        self.country = country
        self.numberOfReboots = numberOfReboots
        self.upgradeOccurred = upgradeOccurred
        self.resetOccurred = resetOccurred
        self.restoreOccurred = restoreOccurred
        self.apiVersion = apiVersion
        self.routerImage = routerImage
        self.routerName = routerName
    }

    // MARK: - Codable conformance

    enum CodingKeys: String, CodingKey {
        case manufacturer = "Manufacturer"
        case manufacturerAlt = "ManuFacturer"  // ZTE router variant
        case manufacturerOUI = "ManufacturerOUI"
        case modelName = "ModelName"
        case description = "Description"
        case productClass = "ProductClass"
        case serialNumber = "SerialNumber"
        case hardwareVersion = "HardwareVersion"
        case softwareVersion = "SoftwareVersion"
        case rescueVersion = "RescueVersion"
        case modemFirmwareVersion = "ModemFirmwareVersion"
        case enabledOptions = "EnabledOptions"
        case additionalHardwareVersion = "AdditionalHardwareVersion"
        case additionalSoftwareVersion = "AdditionalSoftwareVersion"
        case specVersion = "SpecVersion"
        case provisioningCode = "ProvisioningCode"
        case upTime = "UpTime"
        case firstUseDate = "FirstUseDate"
        case deviceLog = "DeviceLog"
        case manufacturerURL = "ManufacturerURL"
        case country = "Country"
        case numberOfReboots = "NumberOfReboots"
        case upgradeOccurred = "UpgradeOccurred"
        case resetOccurred = "ResetOccurred"
        case restoreOccurred = "RestoreOccurred"
        case apiVersion = "ApiVersion"
        case routerImage = "RouterImage"
        case routerName = "RouterName"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle Manufacturer field that may come as "Manufacturer" or "ManuFacturer" (ZTE)
        self.manufacturer = try container.decode(String.self, forFirstOf: .manufacturer, .manufacturerAlt)
        self.manufacturerOUI = try container.decodeIfPresent(String.self, forKey: .manufacturerOUI)
        self.modelName = try container.decode(String.self, forKey: .modelName)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.productClass = try container.decode(String.self, forKey: .productClass)
        self.serialNumber = try container.decode(String.self, forKey: .serialNumber)
        self.hardwareVersion = try container.decode(String.self, forKey: .hardwareVersion)
        self.softwareVersion = try container.decode(String.self, forKey: .softwareVersion)
        self.rescueVersion = try container.decodeIfPresent(String.self, forKey: .rescueVersion)
        self.modemFirmwareVersion = try container.decodeIfPresent(String.self, forKey: .modemFirmwareVersion)
        self.enabledOptions = try container.decodeIfPresent(String.self, forKey: .enabledOptions)
        self.additionalHardwareVersion = try container.decodeIfPresent(String.self, forKey: .additionalHardwareVersion)
        self.additionalSoftwareVersion = try container.decodeIfPresent(String.self, forKey: .additionalSoftwareVersion)
        self.specVersion = try container.decodeIfPresent(String.self, forKey: .specVersion)
        self.provisioningCode = try container.decodeIfPresent(String.self, forKey: .provisioningCode)

        // UpTime uses @FlexibleInt to handle both Int and String values
        self._upTime = try container.decodeIfPresent(FlexibleInt.self, forKey: .upTime) ?? FlexibleInt(wrappedValue: nil)

        self.firstUseDate = try container.decodeIfPresent(String.self, forKey: .firstUseDate)
        self.deviceLog = try container.decodeIfPresent(String.self, forKey: .deviceLog)
        self.manufacturerURL = try container.decodeIfPresent(String.self, forKey: .manufacturerURL)
        self.country = try container.decodeIfPresent(String.self, forKey: .country)
        self.numberOfReboots = try container.decodeIfPresent(Int.self, forKey: .numberOfReboots)
        self.upgradeOccurred = try container.decodeIfPresent(Bool.self, forKey: .upgradeOccurred)
        self.resetOccurred = try container.decodeIfPresent(Bool.self, forKey: .resetOccurred)
        self.restoreOccurred = try container.decodeIfPresent(Bool.self, forKey: .restoreOccurred)
        self.apiVersion = try container.decodeIfPresent(String.self, forKey: .apiVersion)
        self.routerImage = try container.decodeIfPresent(String.self, forKey: .routerImage)
        self.routerName = try container.decodeIfPresent(String.self, forKey: .routerName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encodeIfPresent(manufacturerOUI, forKey: .manufacturerOUI)
        try container.encode(modelName, forKey: .modelName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(productClass, forKey: .productClass)
        try container.encode(serialNumber, forKey: .serialNumber)
        try container.encode(hardwareVersion, forKey: .hardwareVersion)
        try container.encode(softwareVersion, forKey: .softwareVersion)
        try container.encodeIfPresent(rescueVersion, forKey: .rescueVersion)
        try container.encodeIfPresent(modemFirmwareVersion, forKey: .modemFirmwareVersion)
        try container.encodeIfPresent(enabledOptions, forKey: .enabledOptions)
        try container.encodeIfPresent(additionalHardwareVersion, forKey: .additionalHardwareVersion)
        try container.encodeIfPresent(additionalSoftwareVersion, forKey: .additionalSoftwareVersion)
        try container.encodeIfPresent(specVersion, forKey: .specVersion)
        try container.encodeIfPresent(provisioningCode, forKey: .provisioningCode)
        try container.encodeIfPresent(_upTime, forKey: .upTime)
        try container.encodeIfPresent(firstUseDate, forKey: .firstUseDate)
        try container.encodeIfPresent(deviceLog, forKey: .deviceLog)
        try container.encodeIfPresent(manufacturerURL, forKey: .manufacturerURL)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(numberOfReboots, forKey: .numberOfReboots)
        try container.encodeIfPresent(upgradeOccurred, forKey: .upgradeOccurred)
        try container.encodeIfPresent(resetOccurred, forKey: .resetOccurred)
        try container.encodeIfPresent(restoreOccurred, forKey: .restoreOccurred)
        try container.encodeIfPresent(apiVersion, forKey: .apiVersion)
        try container.encodeIfPresent(routerImage, forKey: .routerImage)
        try container.encodeIfPresent(routerName, forKey: .routerName)
    }
}
