import Foundation
import Testing

@testable import Livebox

@Suite("LiveboxAPI Tests")
struct LiveboxAPITests {
    let mockClient: MockLiveboxClient
    let service: LiveboxAPI

    init() {
        mockClient = MockLiveboxClient()
        service = LiveboxAPI(client: mockClient)
    }

    @Test("Fetch capabilities succeeds")
    func testFetchCapabilitiesSuccess() async throws {
        let expectedCapabilities = Capabilities(features: [])
        mockClient.mockedCapabilities = expectedCapabilities

        let capabilities = try await withCheckedThrowingContinuation { continuation in
            service.getCapabilities { result in
                switch result {
                case .success(let capabilities):
                    continuation.resume(returning: capabilities)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        #expect(capabilities.features == expectedCapabilities.features)
    }

    @Test("Fetch capabilities fails")
    func testFetchCapabilitiesFailure() async throws {
        mockClient.shouldFetchCapabilitiesSucceed = false

        let result = try await withCheckedThrowingContinuation { continuation in
            service.getCapabilities { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Get general info succeeds")
    func testGetGeneralInfoSuccess() async throws {
        let expectedInfo = GeneralInfo(
            manufacturer: "Orange",
            manufacturerOUI: "123456",
            modelName: "Livebox 6",
            description: "Orange Livebox",
            productClass: "Orange_Livebox",
            serialNumber: "LK1234567890",
            hardwareVersion: "2.0",
            softwareVersion: "6.40.2.1",
            rescueVersion: nil,
            modemFirmwareVersion: "1.0.0",
            enabledOptions: nil,
            additionalHardwareVersion: nil,
            additionalSoftwareVersion: nil,
            specVersion: nil,
            provisioningCode: nil,
            upTime: 86400,
            firstUseDate: nil,
            deviceLog: nil,
            vendorConfigFileNumberOfEntries: nil,
            manufacturerURL: nil,
            country: "FR",
            numberOfReboots: 5,
            upgradeOccurred: false,
            resetOccurred: false,
            restoreOccurred: false,
            apiVersion: "2.2.7",
            routerImage: "livebox.png",
            routerName: "Livebox"
        )

        mockClient.mockResponses[FeatureID.generalInfo.id] = expectedInfo

        let result = await withCheckedContinuation { continuation in
            service.getGeneralInfo { result in
                continuation.resume(returning: result)
            }
        }

        let info = try result.get()
        #expect(info.manufacturer == expectedInfo.manufacturer)
        #expect(info.modelName == expectedInfo.modelName)
        #expect(info.serialNumber == expectedInfo.serialNumber)
        #expect(info.apiVersion == expectedInfo.apiVersion)
    }

    @Test("Get general info fails when feature not found")
    func testGetGeneralInfoFailure() async throws {
        mockClient.mockErrors["GeneralInfo"] = LiveboxError.featureNotFound("GeneralInfo")

        let result = await withCheckedContinuation { continuation in
            service.getGeneralInfo { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Reboot succeeds")
    func testRebootSuccess() async throws {
        mockClient.mockResponses[FeatureID.reboot.id] = ()

        let result = await withCheckedContinuation { continuation in
            service.reboot { result in
                continuation.resume(returning: result)
            }
        }

        let _ = try result.get()
        #expect(mockClient.requestLog.contains { $0.endpoint.contains("Reboot") })
    }

    @Test("Reboot fails with error")
    func testRebootFailure() async throws {
        mockClient.mockErrors["Reboot"] = LiveboxError.networkError(URLError(.networkConnectionLost))

        let result = await withCheckedContinuation { continuation in
            service.reboot { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Get WiFi interfaces succeeds")
    func testGetWifiInterfacesSuccess() async throws {
        let expectedWifiInterfaces = [
            TestHelpers.createTestWifi(id: "2.4GHz", status: .up, frequency: ._2_4GHz),
            TestHelpers.createTestWifi(id: "5GHz", status: .up, frequency: ._5GHz),
        ]

        mockClient.mockResponses[FeatureID.wifi.id] = expectedWifiInterfaces

        let result = await withCheckedContinuation { continuation in
            service.getWifiInterfaces { result in
                continuation.resume(returning: result)
            }
        }

        let interfaces = try result.get()
        #expect(interfaces.count == 2)
        #expect(interfaces[0].id == "2.4GHz")
        #expect(interfaces[1].id == "5GHz")
    }

    @Test("Get WiFi interfaces fails")
    func testGetWifiInterfacesFailure() async throws {
        mockClient.mockErrors["Wifi"] = LiveboxError.httpError(500, nil)

        let result = await withCheckedContinuation { continuation in
            service.getWifiInterfaces { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Get WiFi interface by ID succeeds")
    func testGetWifiInterfaceSuccess() async throws {
        let expectedInterface = TestHelpers.createTestWlanInterface(id: "2.4GHz", status: .up)

        mockClient.mockResponses[FeatureID.wlanInterface.id] = expectedInterface

        let result = await withCheckedContinuation { continuation in
            service.getWlanInterface(wlanIfc: "2.4GHz") { result in
                continuation.resume(returning: result)
            }
        }

        let interface = try result.get()
        #expect(interface.id == expectedInterface.id)
        #expect(interface.status == expectedInterface.status)
        #expect(interface.accessPoints.count == 1)
    }

    @Test("Get WiFi interface by ID fails")
    func testGetWifiInterfaceFailure() async throws {
        mockClient.mockErrors["WlanInterface"] = LiveboxError.featureNotFound("WlanInterface")

        let result = await withCheckedContinuation { continuation in
            service.getWlanInterface(wlanIfc: "2.4GHz") { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Get access point details succeeds")
    func testGetAccessPointDetailsSuccess() async throws {
        let expectedAccessPoint = TestHelpers.createTestAccessPoint(idx: "001122334455", ssid: "MyWiFi")

        mockClient.mockResponses[FeatureID.wlanAccessPoint.id] = expectedAccessPoint

        let result = await withCheckedContinuation { continuation in
            service.getAccessPoint(wlanIfc: "2.4GHz", wlanAp: "001122334455") { result in
                continuation.resume(returning: result)
            }
        }

        let accessPoint = try result.get()
        #expect(accessPoint.idx == expectedAccessPoint.idx)
        #expect(accessPoint.ssid == expectedAccessPoint.ssid)
        #expect(accessPoint.status == expectedAccessPoint.status)
    }

    @Test("Get access point details fails")
    func testGetAccessPointDetailsFailure() async throws {
        mockClient.mockErrors["WlanAccessPoint"] = LiveboxError.authenticationRequired

        let result = await withCheckedContinuation { continuation in
            service.getAccessPoint(wlanIfc: "2.4GHz", wlanAp: "invalid") { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Update access point details succeeds")
    func testUpdateAccessPointDetailsSuccess() async throws {
        let accessPoint = TestHelpers.createTestAccessPoint().copy(
            status: .up,
            ssid: "UpdatedWiFi",
            password: "newpassword",
            wmmEnable: true,
            uapsdEnable: false,
            apBridgeDisable: false,
            channelConf: .auto,
            bandwidthConf: .auto,
            mode: "802.11ac"
        )

        let expectedUpdatedAccessPoint = TestHelpers.createTestAccessPoint(idx: "001122334455", ssid: "UpdatedWiFi")

        mockClient.mockResponses[FeatureID.wlanAccessPoint.id] = expectedUpdatedAccessPoint

        let result = try await withCheckedThrowingContinuation { continuation in
            service.updateAccessPoint(
                wlanIfc: "2.4GHz",
                wlanAp: "001122334455",
                accessPoint: accessPoint
            ) { result in
                continuation.resume(returning: result)
            }
        }

        let updatedAccessPoint = try result.get()
        #expect(updatedAccessPoint.ssid == "UpdatedWiFi")
        #expect(updatedAccessPoint.mode == "802.11n")  // Note: TestHelpers.createTestAccessPoint uses 802.11n by default
    }

    @Test("Update access point details fails")
    func testUpdateAccessPointDetailsFailure() async throws {
        let accessPoint = TestHelpers.createTestAccessPoint().copy(
            status: .up,
            ssid: "UpdatedWiFi",
            password: "newpassword",
            channelConf: .auto,
            bandwidthConf: .auto,
            mode: "802.11ac"
        )

        mockClient.mockErrors["WlanAccessPoint"] = LiveboxError.operationNotSupported("WlanAccessPoint", "PUT")

        let result = try await withCheckedThrowingContinuation { continuation in
            service.updateAccessPoint(
                wlanIfc: "2.4GHz",
                wlanAp: "001122334455",
                accessPoint: accessPoint
            ) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Request logging works correctly")
    func testRequestLogging() async throws {
        mockClient.mockResponses[FeatureID.generalInfo.id] = GeneralInfo(
            manufacturer: "Orange",
            manufacturerOUI: nil,
            modelName: "Livebox",
            description: nil,
            productClass: "Orange_Livebox",
            serialNumber: "123456789",
            hardwareVersion: "1.0",
            softwareVersion: "1.0",
            rescueVersion: nil,
            modemFirmwareVersion: nil,
            enabledOptions: nil,
            additionalHardwareVersion: nil,
            additionalSoftwareVersion: nil,
            specVersion: nil,
            provisioningCode: nil,
            upTime: nil,
            firstUseDate: nil,
            deviceLog: nil,
            vendorConfigFileNumberOfEntries: nil,
            manufacturerURL: nil,
            country: nil,
            numberOfReboots: nil,
            upgradeOccurred: nil,
            resetOccurred: nil,
            restoreOccurred: nil,
            apiVersion: "1.0",
            routerImage: "image.png",
            routerName: "Livebox"
        )

        let _ = try await withCheckedThrowingContinuation { continuation in
            service.getGeneralInfo { result in
                continuation.resume(returning: result)
            }
        }

        #expect(mockClient.requestLog.count >= 1)
        let lastRequest = mockClient.requestLog.last!
        #expect(lastRequest.endpoint.contains("GeneralInfo"))
        #expect(lastRequest.method == .get)
    }

    @Test("Multiple sequential requests work correctly")
    func testMultipleSequentialRequests() async throws {
        // Setup mock responses
        mockClient.mockResponses[FeatureID.generalInfo.id] = GeneralInfo(
            manufacturer: "Orange",
            manufacturerOUI: nil,
            modelName: "Livebox",
            description: nil,
            productClass: "Orange_Livebox",
            serialNumber: "123456789",
            hardwareVersion: "1.0",
            softwareVersion: "1.0",
            rescueVersion: nil,
            modemFirmwareVersion: nil,
            enabledOptions: nil,
            additionalHardwareVersion: nil,
            additionalSoftwareVersion: nil,
            specVersion: nil,
            provisioningCode: nil,
            upTime: nil,
            firstUseDate: nil,
            deviceLog: nil,
            vendorConfigFileNumberOfEntries: nil,
            manufacturerURL: nil,
            country: nil,
            numberOfReboots: nil,
            upgradeOccurred: nil,
            resetOccurred: nil,
            restoreOccurred: nil,
            apiVersion: "1.0",
            routerImage: "image.png",
            routerName: "Livebox"
        )
        mockClient.mockResponses[FeatureID.wifi.id] = [TestHelpers.createTestWifi(id: "2.4GHz", status: .up, frequency: ._2_4GHz)]
        mockClient.mockResponses[FeatureID.reboot.id] = ()

        // Execute multiple requests
        let infoResult = try await withCheckedThrowingContinuation { continuation in
            service.getGeneralInfo { result in
                continuation.resume(returning: result)
            }
        }

        let wifiResult = try await withCheckedThrowingContinuation { continuation in
            service.getWifiInterfaces { result in
                continuation.resume(returning: result)
            }
        }

        let rebootResult = try await withCheckedThrowingContinuation { continuation in
            service.reboot { result in
                continuation.resume(returning: result)
            }
        }

        // Verify all succeeded
        let _ = try infoResult.get()
        let _ = try wifiResult.get()
        let _ = try rebootResult.get()

        // Verify request log contains all requests
        #expect(mockClient.requestLog.count >= 3)
        let endpoints = mockClient.requestLog.map { $0.endpoint }
        #expect(endpoints.contains { $0.contains("GeneralInfo") })
        #expect(endpoints.contains { $0.contains("Wifi") })
        #expect(endpoints.contains { $0.contains("Reboot") })
    }

    @Test("Service retains capabilities state after fetch")
    func testCapabilitiesStateRetention() async throws {
        let expectedCapabilities = Capabilities(features: [
            Capabilities.Feature(id: "TestFeature", uri: "/test", ops: [.read])
        ])
        mockClient.mockedCapabilities = expectedCapabilities

        // Fetch capabilities twice
        // Both should succeed and return the same capabilities
        let firstResult = try await withCheckedThrowingContinuation { continuation in
            service.getCapabilities { result in
                continuation.resume(with: result)
            }
        }

        let secondResult = try await withCheckedThrowingContinuation { continuation in
            service.getCapabilities { result in
                continuation.resume(with: result)
            }
        }

        #expect(firstResult.features.count == expectedCapabilities.features.count)
        #expect(secondResult.features.count == expectedCapabilities.features.count)
        #expect(firstResult.features.first?.id == expectedCapabilities.features.first?.id)
        #expect(secondResult.features.first?.id == expectedCapabilities.features.first?.id)
    }

    @Test("Service handles path variables correctly")
    func testPathVariablesHandling() async throws {
        let expectedInterface = TestHelpers.createTestWlanInterface(id: "5GHz", status: .up)
        mockClient.mockResponses[FeatureID.wlanInterface.id] = expectedInterface

        let interface = try await withCheckedThrowingContinuation { continuation in
            service.getWlanInterface(wlanIfc: "5GHz") { result in
                continuation.resume(with: result)
            }
        }

        #expect(interface.id == "5GHz")

        // Check that the request was logged with the correct endpoint
        #expect(mockClient.requestLog.count >= 1)
        let lastRequest = mockClient.requestLog.last!
        #expect(lastRequest.endpoint.contains("WlanInterface"))
    }

    @Test("Get connected devices success")
    func testGetConnectedDevicesSuccess() async throws {
        // Setup mock response
        let mockDevices = [
            TestHelpers.createTestDevice(
                physAddress: "AA:BB:CC:DD:EE:FF",
                ipAddress: "192.168.1.100",
                hostName: "Device1",
                alias: "Smart TV",
                interfaceType: .ethernet,
                active: true
            ),
            TestHelpers.createTestDevice(
                physAddress: "11:22:33:44:55:66",
                ipAddress: "192.168.1.101",
                hostName: "Device2",
                alias: "iPhone",
                interfaceType: .wifi,
                active: false
            ),
        ]

        mockClient.mockResponses[FeatureID.connectedDevices.id] = mockDevices

        let result = await withCheckedContinuation { continuation in
            service.getConnectedDevices { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let devices):
            #expect(devices.count == 2)

            // First device
            #expect(devices[0].physAddress == "AA:BB:CC:DD:EE:FF")
            #expect(devices[0].ipAddress == "192.168.1.100")
            #expect(devices[0].hostName == "Device1")
            #expect(devices[0].alias == "Smart TV")
            #expect(devices[0].interfaceType == .ethernet)
            #expect(devices[0].active == true)

            // Second device
            #expect(devices[1].physAddress == "11:22:33:44:55:66")
            #expect(devices[1].ipAddress == "192.168.1.101")
            #expect(devices[1].hostName == "Device2")
            #expect(devices[1].alias == "iPhone")
            #expect(devices[1].interfaceType == .wifi)
            #expect(devices[1].active == false)

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the request was made correctly
        let lastRequest = mockClient.requestLog.last!
        #expect(lastRequest.endpoint.contains("ConnectedDevices"))
        #expect(lastRequest.method == .get)
    }

    @Test("Get connected devices failure")
    func testGetConnectedDevicesFailure() async throws {
        // Setup mock error
        let expectedError = LiveboxError.featureNotFound("ConnectedDevices")
        mockClient.mockErrors["ConnectedDevices"] = expectedError

        let result = await withCheckedContinuation { continuation in
            service.getConnectedDevices { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "ConnectedDevices")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Get connected devices empty list")
    func testGetConnectedDevicesEmptyList() async throws {
        // Setup mock response with empty array
        mockClient.mockResponses[FeatureID.connectedDevices.id] = [DeviceInfo]()

        let result = await withCheckedContinuation { continuation in
            service.getConnectedDevices { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let devices):
            #expect(devices.isEmpty)
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test("Get connected devices with mixed interface types")
    func testGetConnectedDevicesWithMixedInterfaceTypes() async throws {
        // Setup mock response with devices of different interface types
        let mockDevices = [
            TestHelpers.createTestDevice(
                physAddress: "AA:BB:CC:DD:EE:FF",
                ipAddress: "192.168.1.100",
                hostName: "EthernetDevice",
                alias: "Desktop PC",
                interfaceType: .ethernet,
                active: true
            ),
            TestHelpers.createTestDevice(
                physAddress: "11:22:33:44:55:66",
                ipAddress: "192.168.1.101",
                hostName: "WiFiDevice",
                alias: "Smartphone",
                interfaceType: .wifi,
                active: true
            ),
            TestHelpers.createTestDevice(
                physAddress: "77:88:99:AA:BB:CC",
                ipAddress: "192.168.1.102",
                hostName: "WiFi5Device",
                alias: "Smart TV",
                interfaceType: .wifi50,
                active: false
            ),
        ]

        mockClient.mockResponses[FeatureID.connectedDevices.id] = mockDevices

        let result = await withCheckedContinuation { continuation in
            service.getConnectedDevices { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case .success(let devices):
            #expect(devices.count == 3)

            // Verify different interface types
            let interfaceTypes = Set(devices.map { $0.interfaceType })
            #expect(interfaceTypes.contains(.ethernet))
            #expect(interfaceTypes.contains(.wifi))
            #expect(interfaceTypes.contains(.wifi50))

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test("Get device details success")
    func testGetDeviceDetailsSuccess() async throws {
        // Given
        let mac = "AABBCCDDEEFF"
        let expectedDeviceDetails = TestHelpers.createTestDeviceDetails(
            physAddress: "AA:BB:CC:DD:EE:FF",
            hostName: "TestDevice",
            alias: "My Test Device"
        )

        mockClient.mockResponses[FeatureID.connectedDevicesMac.id] = expectedDeviceDetails

        // When
        let result = await withCheckedContinuation { continuation in
            service.getDeviceDetail(mac: mac) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let deviceDetails):
            #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
            #expect(deviceDetails.hostName == "TestDevice")
            #expect(deviceDetails.alias == "My Test Device")

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("ConnectedDevicesMac") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .get)
    }

    @Test("Get device detail failure")
    func testGetDeviceDetailFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let expectedError = LiveboxError.featureNotFound("ConnectedDevicesMac")
        mockClient.mockErrors["ConnectedDevicesMac"] = expectedError

        // When
        let result = await withCheckedContinuation { continuation in
            service.getDeviceDetail(mac: mac) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "ConnectedDevicesMac")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Set device alias success")
    func testSetDeviceAliasSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let newAlias = "My Smart Device"
        let expectedDeviceDetails = TestHelpers.createTestDeviceDetails(
            physAddress: "AA:BB:CC:DD:EE:FF",
            alias: newAlias
        )

        mockClient.mockResponses[FeatureID.connectedDevicesMac.id] = expectedDeviceDetails

        // When
        let result = await withCheckedContinuation { continuation in
            service.setDeviceAlias(mac: mac, alias: newAlias) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let deviceDetails):
            #expect(deviceDetails.alias == newAlias)
            #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("ConnectedDevicesMac") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .put)
    }

    @Test("Set device alias failure")
    func testSetDeviceAliasFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let newAlias = "My Smart Device"
        let expectedError = LiveboxError.featureNotFound("ConnectedDevicesMac")
        mockClient.mockErrors["ConnectedDevicesMac"] = expectedError

        // When
        let result = await withCheckedContinuation { continuation in
            service.setDeviceAlias(mac: mac, alias: newAlias) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "ConnectedDevicesMac")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Get device schedules success")
    func testGetDeviceSchedulesSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let expectedSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 2),
            TestHelpers.createTestSchedule(id: 168),
        ]

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.getDeviceSchedules(mac: mac) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 3)
            #expect(schedules[0].id == "1")
            #expect(schedules[1].id == "2")
            #expect(schedules[2].id == "168")

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .get)
    }

    @Test("Get device schedules failure")
    func testGetDeviceSchedulesFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let expectedError = LiveboxError.featureNotFound("PcDevicesMacSchedules")
        mockClient.mockErrors["PcDevicesMacSchedules"] = expectedError

        // When
        let result = await withCheckedContinuation { continuation in
            service.getDeviceSchedules(mac: mac) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "PcDevicesMacSchedules")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Get device schedules empty list")
    func testGetDeviceSchedulesEmptyList() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let expectedSchedules: Schedules = []

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.getDeviceSchedules(mac: mac) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.isEmpty)
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test("Add device schedules success")
    func testAddDeviceSchedulesSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let inputSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 25),
            TestHelpers.createTestSchedule(id: 168),
        ]
        let expectedSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 25),
            TestHelpers.createTestSchedule(id: 168),
        ]

        // Mock both the status change call and the schedule addition call
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()  // For changeDeviceScheduleStatus
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.addDeviceSchedules(mac: mac, schedules: inputSchedules) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 3)
            #expect(schedules[0].id == "1")
            #expect(schedules[1].id == "25")
            #expect(schedules[2].id == "168")

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the schedule addition request was made (should be in the request log)
        let scheduleRequest = mockClient.requestLog.filter { $0.endpoint.contains("PcDevicesMacSchedules") }.last
        #expect(scheduleRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(scheduleRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(scheduleRequest?.method == .post)
    }

    @Test("Add device schedules failure")
    func testAddDeviceSchedulesFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let inputSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 168),
        ]
        let expectedError = LiveboxError.featureNotFound("PcDevicesMac")
        mockClient.mockErrors["PcDevicesMac"] = expectedError

        // When
        let result = await withCheckedContinuation { continuation in
            service.addDeviceSchedules(mac: mac, schedules: inputSchedules) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "PcDevicesMac")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Add device schedules with empty array")
    func testAddDeviceSchedulesWithEmptyArray() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let inputSchedules: Schedules = []
        let expectedSchedules: Schedules = []

        // Mock both the status change call and the schedule addition call
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()  // For changeDeviceScheduleStatus
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.addDeviceSchedules(mac: mac, schedules: inputSchedules) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.isEmpty)
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the schedule addition request was made (last request should be the schedule addition)
        let scheduleRequest = mockClient.requestLog.filter { $0.endpoint.contains("PcDevicesMacSchedules") }.last
        #expect(scheduleRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(scheduleRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(scheduleRequest?.method == .post)
    }

    @Test("Add device schedules with type-safe schedules")
    func testAddDeviceSchedulesWithTypeSafeSchedules() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let inputSchedules: Schedules = [
            Schedule(day: .monday, hour: 8)!,  // Monday 8:00-9:00 AM
            Schedule(day: .wednesday, hour: 12)!,  // Wednesday 12:00-1:00 PM
            Schedule(day: .friday, hour: 17)!,  // Friday 5:00-6:00 PM
        ]
        let expectedSchedules = inputSchedules

        // Mock both the status change call and the schedule addition call
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()  // For changeDeviceScheduleStatus
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.addDeviceSchedules(mac: mac, schedules: inputSchedules) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 3)

            // Verify type-safe properties
            #expect(schedules[0].scheduleID.dayOfWeek == .monday)  // Monday
            #expect(schedules[0].scheduleID.hourOfDay == 8)  // 8 AM
            #expect(schedules[1].scheduleID.dayOfWeek == .wednesday)  // Wednesday
            #expect(schedules[1].scheduleID.hourOfDay == 12)  // 12 PM
            #expect(schedules[2].scheduleID.dayOfWeek == .friday)  // Friday
            #expect(schedules[2].scheduleID.hourOfDay == 17)  // 5 PM

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the schedule addition request was made (should be in the request log)
        let scheduleRequest = mockClient.requestLog.filter { $0.endpoint.contains("PcDevicesMacSchedules") }.last
        #expect(scheduleRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(scheduleRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(scheduleRequest?.method == .post)
    }

    @Test("Change device schedule status success")
    func testChangeDeviceScheduleStatusSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let status = DeviceScheduleStatus(mac: mac, status: .enabled)
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()

        // When
        let result = await withCheckedContinuation { continuation in
            service.changeDeviceScheduleStatus(mac: mac, status: status) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            // Verify the correct request was made
            let lastRequest = mockClient.requestLog.last
            #expect(lastRequest?.endpoint.contains("PcDevicesMac") == true)
            #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }
    }

    @Test("Change device schedule status failure")
    func testChangeDeviceScheduleStatusFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let status = DeviceScheduleStatus(mac: mac, status: .disabled)
        mockClient.mockErrors["PcDevicesMac"] = LiveboxError.featureNotFound("PcDevicesMac")

        // When
        let result = await withCheckedContinuation { continuation in
            service.changeDeviceScheduleStatus(mac: mac, status: status) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "PcDevicesMac")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Delete device schedules success")
    func testDeleteDeviceSchedulesSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedulesToDelete: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 25),
        ]
        let remainingSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 168)
        ]

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = remainingSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.deleteDeviceSchedules(mac: mac, schedules: schedulesToDelete) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 1)
            #expect(schedules[0].id == "168")

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .delete)
    }

    @Test("Delete device schedules failure")
    func testDeleteDeviceSchedulesFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedulesToDelete: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 168),
        ]
        let expectedError = LiveboxError.featureNotFound("PcDevicesMacSchedules")
        mockClient.mockErrors["PcDevicesMacSchedules"] = expectedError

        // When
        let result = await withCheckedContinuation { continuation in
            service.deleteDeviceSchedules(mac: mac, schedules: schedulesToDelete) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success:
            Issue.record("Expected failure but got success")
        case .failure(let error):
            if case .featureNotFound(let feature) = error {
                #expect(feature == "PcDevicesMacSchedules")
            } else {
                Issue.record("Expected LiveboxError.featureNotFound but got: \(error)")
            }
        }
    }

    @Test("Delete device schedules with empty array")
    func testDeleteDeviceSchedulesWithEmptyArray() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedulesToDelete: Schedules = []
        let remainingSchedules: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 168),
        ]

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = remainingSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.deleteDeviceSchedules(mac: mac, schedules: schedulesToDelete) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 2)
            #expect(schedules[0].id == "1")
            #expect(schedules[1].id == "168")
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .delete)
    }

    @Test("Delete device schedules with type-safe schedules")
    func testDeleteDeviceSchedulesWithTypeSafeSchedules() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedulesToDelete: Schedules = [
            Schedule(day: .monday, hour: 8)!,  // Monday 8:00-9:00 AM
            Schedule(day: .wednesday, hour: 12)!,  // Wednesday 12:00-1:00 PM
        ]
        let remainingSchedules: Schedules = [
            Schedule(day: .friday, hour: 17)!  // Friday 5:00-6:00 PM
        ]

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = remainingSchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.deleteDeviceSchedules(mac: mac, schedules: schedulesToDelete) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.count == 1)

            // Verify type-safe properties of remaining schedule
            #expect(schedules[0].scheduleID.dayOfWeek == .friday)  // Friday
            #expect(schedules[0].scheduleID.hourOfDay == 17)  // 5 PM

        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .delete)
    }

    @Test("Delete all device schedules")
    func testDeleteAllDeviceSchedules() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let allSchedulesToDelete: Schedules = [
            TestHelpers.createTestSchedule(id: 1),
            TestHelpers.createTestSchedule(id: 25),
            TestHelpers.createTestSchedule(id: 168),
        ]
        let emptySchedules: Schedules = []

        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = emptySchedules

        // When
        let result = await withCheckedContinuation { continuation in
            service.deleteDeviceSchedules(mac: mac, schedules: allSchedulesToDelete) { result in
                continuation.resume(returning: result)
            }
        }

        // Then
        switch result {
        case .success(let schedules):
            #expect(schedules.isEmpty)
        case .failure(let error):
            Issue.record("Expected success but got error: \(error)")
        }

        // Verify the correct request was made
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMacSchedules") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
        #expect(lastRequest?.method == .delete)
    }

    @Test("Update base URL with URL succeeds")
    func testUpdateBaseURLWithURLSuccess() throws {
        let newURL = URL(string: "http://192.168.1.100")!
        let originalURL = service.baseURL

        service.updateBaseURL(newURL)

        #expect(service.baseURL == newURL)
        #expect(service.baseURL != originalURL)
        // Authentication state should be preserved (no credentials were set initially)
        #expect(service.isAuthenticated == false)
    }

    @Test("Update base URL with string succeeds")
    func testUpdateBaseURLWithStringSuccess() throws {
        let newURLString = "http://192.168.1.200"
        let originalURL = service.baseURL

        try service.updateBaseURL(newURLString)

        #expect(service.baseURL.absoluteString == newURLString)
        #expect(service.baseURL != originalURL)
    }

    @Test("Update base URL with invalid string fails")
    func testUpdateBaseURLWithInvalidStringFails() {
        let invalidURLString = ""

        #expect(throws: LiveboxError.self) {
            try service.updateBaseURL(invalidURLString)
        }
    }

    @Test("Update base URL preserves capabilities by default")
    func testUpdateBaseURLPreservesCapabilitiesByDefault() async throws {
        // First, authenticate and fetch capabilities
        let credentials = ("UsrAdmin", "testpass")
        let _ = try await withCheckedThrowingContinuation { continuation in
            service.login(username: credentials.0, password: credentials.1) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(service.isAuthenticated == true)

        // Now change the base URL without clearing capabilities
        let newURL = URL(string: "http://192.168.1.100")!
        service.updateBaseURL(newURL)

        // Capabilities state should be preserved, and authentication should remain
        #expect(service.isAuthenticated == true)  // Credentials are preserved
        #expect(service.baseURL == newURL)
        // Note: We can't directly test capabilities state in the current API structure
    }

    @Test("Update base URL can clear capabilities when requested")
    func testUpdateBaseURLCanClearCapabilities() async throws {
        // First, authenticate and fetch capabilities
        let credentials = ("UsrAdmin", "testpass")
        let _ = try await withCheckedThrowingContinuation { continuation in
            service.login(username: credentials.0, password: credentials.1) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(service.isAuthenticated == true)

        // Now change the base URL and explicitly clear capabilities
        let newURL = URL(string: "http://192.168.1.100")!
        service.updateBaseURL(newURL, clearCapabilities: true)

        // Authentication should remain but capabilities should be cleared
        #expect(service.isAuthenticated == true)  // Credentials are preserved
        #expect(service.baseURL == newURL)
        // Note: We can't directly test capabilities state in the current API structure
    }

    @Test("Update base URL with string can clear capabilities")
    func testUpdateBaseURLWithStringCanClearCapabilities() throws {
        let newURLString = "http://192.168.1.200"
        let originalURL = service.baseURL

        try service.updateBaseURL(newURLString, clearCapabilities: true)

        #expect(service.baseURL.absoluteString == newURLString)
        #expect(service.baseURL != originalURL)
    }

    @Test("Update base URL preserves authentication")
    func testUpdateBaseURLPreservesAuthentication() throws {
        // Set up authentication
        try service.updateCredentials(username: "UsrAdmin", password: "testpass")
        #expect(service.isAuthenticated == true)
        #expect(service.currentUsername == "UsrAdmin")

        // Change the base URL
        let newURL = URL(string: "http://192.168.1.100")!
        service.updateBaseURL(newURL)

        // Authentication should be preserved
        #expect(service.isAuthenticated == true)
        #expect(service.currentUsername == "UsrAdmin")
        #expect(service.baseURL == newURL)
    }

    @Test("Get WLAN schedule status succeeds")
    func testGetWlanScheduleStatusSuccess() async throws {
        // Given
        let wlanIfc = "wl0"
        let wlanAp = "ap0"
        let expectedStatus = WlanScheduleStatus(isEnabled: true)
        mockClient.mockResponses[FeatureID.wlanScheduleEnable.id] = expectedStatus

        // When
        let status: WlanScheduleStatus = try await withCheckedThrowingContinuation { continuation in
            service.getWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp) { result in
                continuation.resume(with: result)
            }
        }

        // Then
        #expect(status.isEnabled == true)
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("WlanScheduleEnable") == true)
        #expect(lastRequest?.endpoint.contains(wlanIfc) == true)
        #expect(lastRequest?.endpoint.contains(wlanAp) == true)
    }

    @Test("Get WLAN schedule status fails")
    func testGetWlanScheduleStatusFailure() async throws {
        // Given
        let wlanIfc = "wl0"
        let wlanAp = "ap0"
        mockClient.mockErrors["WlanScheduleEnable"] = LiveboxError.featureNotFound("WlanScheduleEnable")

        // When/Then
        let result: Result<WlanScheduleStatus, LiveboxError> = await withCheckedContinuation { continuation in
            service.getWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }

    @Test("Change WLAN schedule status succeeds")
    func testChangeWlanScheduleStatusSuccess() async throws {
        // Given
        let wlanIfc = "wl0"
        let wlanAp = "ap0"
        let status = WlanScheduleStatus(isEnabled: false)
        mockClient.mockResponses[FeatureID.wlanScheduleEnable.id] = ()

        // When
        try await withCheckedThrowingContinuation { continuation in
            service.changeWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp, status: status) { result in
                continuation.resume(with: result)
            }
        }

        // Then
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("WlanScheduleEnable") == true)
        #expect(lastRequest?.endpoint.contains(wlanIfc) == true)
        #expect(lastRequest?.endpoint.contains(wlanAp) == true)
        #expect(lastRequest?.method == .put)
    }

    @Test("Change WLAN schedule status fails")
    func testChangeWlanScheduleStatusFailure() async throws {
        // Given
        let wlanIfc = "wl0"
        let wlanAp = "ap0"
        let status = WlanScheduleStatus(isEnabled: true)
        mockClient.mockErrors["WlanScheduleEnable"] = LiveboxError.featureNotFound("WlanScheduleEnable")

        // When/Then
        let result: Result<Void, LiveboxError> = await withCheckedContinuation { continuation in
            service.changeWlanScheduleStatus(wlanIfc: wlanIfc, wlanAp: wlanAp, status: status) { result in
                continuation.resume(returning: result)
            }
        }

        #expect(throws: LiveboxError.self) {
            try result.get()
        }
    }
}

// MARK: - Test Helper Functions
// Helper functions have been moved to Tests/LiveboxTests/Helpers/TestHelpers.swift
// Access them via the TestHelpers namespace: TestHelpers.createTestDevice(), etc.
