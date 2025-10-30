import Foundation

@testable import Livebox

/// Namespace for test helper functions
public enum TestHelpers {

    // MARK: - Test Helper Functions

    /// Creates a test WiFi object
    /// - Parameters:
    ///   - id: The WiFi ID
    ///   - status: The WiFi status
    ///   - frequency: The WiFi frequency
    /// - Returns: A Wifi object for testing
    public static func createTestWifi(id: String, status: Wifi.Status = .up, frequency: Wifi.Frequency = ._2_4GHz) -> Wifi {
        Wifi(id: id, status: status, frequency: frequency)
    }

    /// Creates a test WlanInterface object
    /// - Parameters:
    ///   - id: The interface ID
    ///   - status: The interface status
    /// - Returns: A WlanInterface object for testing
    public static func createTestWlanInterface(id: String, status: WlanInterface.Status = .up) -> WlanInterface {
        WlanInterface(
            id: id,
            status: status,
            frequency: "2.4GHz",
            lastChangeTime: 1_234_567_890,
            lastChange: 1_234_567_890,
            accessPoints: [
                .init(
                    bssid: "00:11:22:33:44:55",
                    ssid: "TestWiFi",
                    status: .up,
                    remainingDuration: nil
                )
            ]
        )
    }

    /// Creates a test Schedule object
    /// - Parameter id: The schedule ID
    /// - Returns: A Schedule object for testing
    public static func createTestSchedule(id: Int = 1) -> Schedule {
        Schedule(scheduleID: ScheduleID(rawValue: id)!)
    }

    /// Creates a test Device object
    /// - Parameters:
    ///   - physAddress: The physical address (MAC)
    ///   - ipAddress: The IP address
    ///   - ipV6Address: The IPv6 address
    ///   - hostName: The hostname
    ///   - alias: The alias
    ///   - interfaceType: The interface type
    ///   - active: Whether the device is active
    /// - Returns: A Device object for testing
    public static func createTestDevice(
        physAddress: String = "AA:BB:CC:DD:EE:FF",
        ipAddress: String = "192.168.1.100",
        ipV6Address: String = "",
        hostName: String = "TestDevice",
        alias: String = "Test Device",
        interfaceType: DeviceInfo.InterfaceType = .ethernet,
        active: Bool = true
    ) -> DeviceInfo {
        DeviceInfo(
            physAddress: physAddress,
            ipAddress: ipAddress,
            ipV6Address: ipV6Address,
            hostName: hostName,
            alias: alias,
            interfaceType: interfaceType,
            active: active
        )
    }

    /// Creates a test AccessPoint object
    /// - Parameters:
    ///   - idx: The access point index
    ///   - ssid: The SSID
    /// - Returns: An AccessPoint object for testing
    public static func createTestAccessPoint(
        idx: String = "001122334455",
        ssid: String = "TestWiFi",
        wmmEnable: Bool? = nil,
        uapsdEnable: Bool? = nil,
        apBridgeDisable: Bool? = nil
    ) -> AccessPoint {
        AccessPoint(
            idx: idx,
            bssid: "00:11:22:33:44:55",
            type: .home,
            manner: .combined,
            status: .up,
            ssid: ssid,
            password: "testpassword",
            ssidAdvertisementEnabled: true,
            retryLimit: 3,
            wmmCapability: true,
            uapsdCapability: false,
            wmmEnable: wmmEnable,
            uapsdEnable: uapsdEnable,
            maxStations: 32,
            apBridgeDisable: apBridgeDisable,
            channelConf: .auto,
            channel: 6,
            bandwidthConf: .auto,
            bandwidth: "20MHz",
            mode: "802.11n",
            schedulingAllowed: true
        )
    }

    /// Creates a test GeneralInfo object
    /// - Returns: A GeneralInfo object for testing
    public static func createTestGeneralInfo() -> GeneralInfo {
        GeneralInfo(
            manufacturer: "TestManufacturer",
            manufacturerOUI: "AABBCC",
            modelName: "TestModel",
            description: "Test Description",
            productClass: "TestRouter",
            serialNumber: "123456",
            hardwareVersion: "1.0",
            softwareVersion: "2.0",
            rescueVersion: "1.5",
            modemFirmwareVersion: "3.0",
            enabledOptions: "TestOptions",
            additionalHardwareVersion: "1.1",
            additionalSoftwareVersion: "1.0",
            specVersion: "1.0",
            provisioningCode: "TEST123",
            upTime: 12345,
            firstUseDate: "2023-01-01T00:00:00Z",
            deviceLog: "No errors",
            manufacturerURL: "https://example.com",
            country: "US",
            numberOfReboots: 5,
            upgradeOccurred: false,
            resetOccurred: false,
            restoreOccurred: false,
            apiVersion: "1.0",
            routerImage: "router.png",
            routerName: "TestRouter"
        )
    }

    /// Creates a test DeviceDetails object
    /// - Parameters:
    ///   - physAddress: The physical address (MAC)
    ///   - ipAddress: The IP address
    ///   - ipV6Address: The IPv6 address
    ///   - addressSource: The address source
    ///   - detectedTypes: The detected types
    ///   - leaseTimeRemaining: The lease time remaining
    ///   - vendorClassID: The vendor class ID
    ///   - clientID: The client ID
    ///   - userClassID: The user class ID
    ///   - hostName: The hostname
    ///   - alias: The alias
    ///   - uPnPNames: The UPnP names
    ///   - mDNSNames: The mDNS names
    ///   - lLTDDevice: Whether it's an LLTD device
    ///   - SSID: The SSID
    ///   - active: Whether the device is active
    ///   - lastConnection: The last connection time
    ///   - tags: The tags
    ///   - layer2Interface: The layer 2 interface
    ///   - interfaceType: The interface type
    ///   - manufacturerOUI: The manufacturer OUI
    ///   - serialNumber: The serial number
    ///   - productClass: The product class
    ///   - deviceIcon: The device icon
    ///   - deviceLocation: The device location
    ///   - deviceType: The device type
    ///   - deviceSource: The device source
    ///   - deviceID: The device ID
    /// - Returns: A DeviceDetails object for testing
    public static func createTestDeviceDetails(
        physAddress: String = "AA:BB:CC:DD:EE:FF",
        ipAddress: String = "192.168.1.100",
        ipV6Address: String = "",
        addressSource: String? = "DHCP",
        detectedTypes: String? = nil,
        leaseTimeRemaining: Int? = 3600,
        vendorClassID: String? = nil,
        clientID: String? = nil,
        userClassID: String? = nil,
        hostName: String = "TestDevice",
        alias: String = "Test Device",
        uPnPNames: String? = nil,
        mDNSNames: String? = nil,
        lLTDDevice: Bool? = false,
        SSID: String = "TestWiFi",
        active: Bool = true,
        lastConnection: String = "2023-01-01T12:00:00Z",
        tags: String = "",
        layer2Interface: Int = 1,
        interfaceType: String = "Ethernet",
        manufacturerOUI: String? = "AA:BB:CC",
        serialNumber: String? = nil,
        productClass: String? = nil,
        deviceIcon: String? = nil,
        deviceLocation: String? = nil,
        deviceType: String = "Computer",
        deviceSource: String? = "DHCP",
        deviceID: String = "test-device-id"
    ) -> DeviceDetail {
        DeviceDetail(
            physAddress: physAddress,
            ipAddress: ipAddress,
            ipV6Address: ipV6Address,
            addressSource: addressSource,
            detectedTypes: detectedTypes,
            leaseTimeRemaining: leaseTimeRemaining,
            vendorClassID: vendorClassID,
            clientID: clientID,
            userClassID: userClassID,
            hostName: hostName,
            alias: alias,
            uPnPNames: uPnPNames,
            mDNSNames: mDNSNames,
            lLTDDevice: lLTDDevice,
            SSID: SSID,
            active: active,
            lastConnection: lastConnection,
            tags: tags,
            layer2Interface: layer2Interface,
            interfaceType: interfaceType,
            manufacturerOUI: manufacturerOUI,
            serialNumber: serialNumber,
            productClass: productClass,
            deviceIcon: deviceIcon,
            deviceLocation: deviceLocation,
            deviceType: deviceType,
            deviceSource: deviceSource,
            deviceID: deviceID
        )
    }
}
