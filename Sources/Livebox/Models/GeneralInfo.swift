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

    /// Uptime in seconds
    public let upTime: Int?

    /// First use date
    public let firstUseDate: String?

    /// Device log
    public let deviceLog: String?

    /// Number of vendor config file entries
    public let vendorConfigFileNumberOfEntries: String?

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

    private enum CodingKeys: String, CodingKey {
        case manufacturer = "Manufacturer"
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
        case vendorConfigFileNumberOfEntries = "VendorConfigFileNumberOfEntries"
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
        vendorConfigFileNumberOfEntries: String? = nil,
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
        self.upTime = upTime
        self.firstUseDate = firstUseDate
        self.deviceLog = deviceLog
        self.vendorConfigFileNumberOfEntries = vendorConfigFileNumberOfEntries
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
}
