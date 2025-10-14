import Foundation
import Testing

@testable import Livebox
@testable import LiveboxAsync

@Suite("LiveboxAPI Async Tests")
struct LiveboxAPIAsyncTests {
    var mockClient: MockLiveboxClient
    var service: LiveboxAPI

    init() {
        mockClient = MockLiveboxClient()
        service = LiveboxAPI(client: mockClient)
    }

    @Test("Async typealias works correctly")
    func testAsyncTypeAlias() throws {
        // This verifies the typealias is properly set
        let asyncService: AsyncLiveboxAPI = service
        #expect(asyncService === service, "AsyncLiveboxAPI should just be a typealias for LiveboxAPI")
    }

    @Test("Fetch capabilities async success")
    func testFetchCapabilitiesAsyncSuccess() async throws {
        // Given
        mockClient.shouldFetchCapabilitiesSucceed = true

        // When
        let capabilities = try await service.getCapabilities()

        // Then
        #expect(capabilities.features.count > 0)
        #expect(mockClient.requestLog.count == 1)
        #expect(mockClient.requestLog[0].endpoint == "/sysbus/Capabilities:get")
    }

    @Test("Fetch capabilities async failure")
    func testFetchCapabilitiesAsyncFailure() async throws {
        // Given
        mockClient.shouldFetchCapabilitiesSucceed = false

        // When/Then
        do {
            _ = try await service.getCapabilities()
            Issue.record("Expected failure but got success")
        } catch {
            #expect(!mockClient.shouldFetchCapabilitiesSucceed)
        }
    }

    @Test("Get general info async success")
    func testGetGeneralInfoAsyncSuccess() async throws {
        // Given
        let expectedInfo = TestHelpers.createTestGeneralInfo()
        mockClient.mockResponses[FeatureID.generalInfo.id] = expectedInfo

        // When
        let info = try await service.getGeneralInfo()

        // Then
        #expect(info.productClass == "TestRouter")
        #expect(info.serialNumber == "123456")
    }

    @Test("Get general info async failure")
    func testGetGeneralInfoAsyncFailure() async throws {
        // Given
        mockClient.mockErrors["GeneralInfo"] = LiveboxError.featureNotFound("GeneralInfo")

        // When/Then
        do {
            _ = try await service.getGeneralInfo()
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "GeneralInfo")
        }
    }

    @Test("Reboot async success")
    func testRebootAsyncSuccess() async throws {
        // Given
        mockClient.mockResponses[FeatureID.reboot.id] = true

        // When
        try await service.reboot()

        // Then
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("Reboot") == true)
    }

    @Test("Reboot async failure")
    func testRebootAsyncFailure() async throws {
        // Given
        mockClient.mockErrors["Reboot"] = LiveboxError.featureNotFound("Reboot")

        // When/Then
        do {
            try await service.reboot()
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "Reboot")
        }
    }

    @Test("Get WiFi interfaces async success")
    func testGetWifiInterfacesAsyncSuccess() async throws {
        // Given
        let expectedWifi = [
            Wifi(id: "wl0", status: .up, frequency: ._2_4GHz),
            Wifi(id: "wl1", status: .down, frequency: ._5GHz),
        ]
        mockClient.mockResponses[FeatureID.wifi.id] = expectedWifi

        // When
        let interfaces = try await service.getWifiInterfaces()

        // Then
        #expect(interfaces.count == 2)
        #expect(interfaces[0].id == "wl0")
        #expect(interfaces[1].id == "wl1")
    }

    @Test("Get WiFi interfaces async failure")
    func testGetWifiInterfacesAsyncFailure() async throws {
        // Given
        mockClient.mockErrors["Wifi"] = LiveboxError.featureNotFound("Wifi")

        // When/Then
        do {
            _ = try await service.getWifiInterfaces()
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "Wifi")
        }
    }

    @Test("Get WiFi interface async success")
    func testGetWifiInterfaceAsyncSuccess() async throws {
        // Given
        let expectedInterface = WlanInterface(
            id: "wl0",
            status: .up,
            frequency: "2.4GHz",
            lastChangeTime: 1_234_567_890,
            lastChange: 1_234_567_890,
            accessPoints: []
        )
        mockClient.mockResponses[FeatureID.wlanInterface.id] = expectedInterface

        // When
        let interface = try await service.getWlanInterface(wlanIfc: "wl0")

        // Then
        #expect(interface.id == "wl0")
        #expect(interface.status == .up)
    }

    @Test("Get WiFi interface async failure")
    func testGetWifiInterfaceAsyncFailure() async throws {
        // Given
        mockClient.mockErrors["WlanInterface"] = LiveboxError.featureNotFound("WlanInterface")

        // When/Then
        do {
            _ = try await service.getWlanInterface(wlanIfc: "wl0")
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "WlanInterface")
        }
    }

    @Test("Get device schedules async success")
    func testGetDeviceSchedulesAsyncSuccess() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        let expectedSchedules: Schedules = [
            Schedule(scheduleID: ScheduleID(rawValue: 1)!),
            Schedule(scheduleID: ScheduleID(rawValue: 168)!),
        ]
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let schedules = try await service.getDeviceSchedules(mac: deviceId)

        // Then
        #expect(schedules.count == 2)
        #expect(schedules[0].id == "1")
        #expect(schedules[1].id == "168")
    }

    @Test("Get device schedules async failure")
    func testGetDeviceSchedulesAsyncFailure() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        mockClient.mockErrors["PcDevicesMacSchedules"] = LiveboxError.featureNotFound("PcDevicesMacSchedules")

        // When/Then
        do {
            _ = try await service.getDeviceSchedules(mac: deviceId)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "PcDevicesMacSchedules")
        }
    }

    @Test("Add device schedules async success")
    func testAddDeviceSchedulesAsyncSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let inputSchedules: Schedules = [
            Schedule(day: .monday, hour: 8)!,  // Monday 8 AM
            Schedule(day: .friday, hour: 17)!,  // Friday 5 PM
        ]
        let expectedSchedules = inputSchedules

        // Mock both the status change call and the schedule addition call
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()  // For changeDeviceScheduleStatus
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = expectedSchedules

        // When
        let schedules = try await service.addDeviceSchedules(
            mac: mac,
            schedules: inputSchedules
        )

        // Then
        #expect(schedules.count == 2)
        #expect(schedules[0].scheduleID.dayOfWeek == .monday)
        #expect(schedules[0].scheduleID.hourOfDay == 8)
        #expect(schedules[1].scheduleID.dayOfWeek == .friday)
        #expect(schedules[1].scheduleID.hourOfDay == 17)
    }

    @Test("Add device schedules async failure")
    func testAddDeviceSchedulesAsyncFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedules = [Schedule(scheduleID: ScheduleID(rawValue: 1)!)]

        // Mock the status change to fail first
        mockClient.mockErrors["PcDevicesMac"] = LiveboxError.featureNotFound("PcDevicesMac")

        // When/Then
        do {
            _ = try await service.addDeviceSchedules(mac: mac, schedules: schedules)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "PcDevicesMac")
        }
    }

    @Test("Add device schedules async failure on schedule addition")
    func testAddDeviceSchedulesAsyncFailureOnScheduleAddition() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedules = [Schedule(scheduleID: ScheduleID(rawValue: 1)!)]

        // Mock the status change to succeed but schedule addition to fail
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()  // Status change succeeds
        mockClient.mockErrors["PcDevicesMacSchedules"] = LiveboxError.featureNotFound("PcDevicesMacSchedules")

        // When/Then
        do {
            _ = try await service.addDeviceSchedules(mac: mac, schedules: schedules)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "PcDevicesMacSchedules")
        }
    }

    @Test("Change device schedule status async success")
    func testChangeDeviceScheduleStatusAsyncSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let status = DeviceScheduleStatus(mac: mac, status: .enabled)
        mockClient.mockResponses[FeatureID.pcDevicesMac.id] = ()

        // When
        try await service.changeDeviceScheduleStatus(mac: mac, status: status)

        // Then
        let lastRequest = mockClient.requestLog.last
        #expect(lastRequest?.endpoint.contains("PcDevicesMac") == true)
        #expect(lastRequest?.endpoint.contains(mac.removingColons) == true)
    }

    @Test("Change device schedule status async failure")
    func testChangeDeviceScheduleStatusAsyncFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let status = DeviceScheduleStatus(mac: mac, status: .disabled)
        mockClient.mockErrors["PcDevicesMac"] = LiveboxError.featureNotFound("PcDevicesMac")

        // When/Then
        do {
            try await service.changeDeviceScheduleStatus(mac: mac, status: status)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "PcDevicesMac")
        }
    }

    @Test("Delete device schedules async success")
    func testDeleteDeviceSchedulesAsyncSuccess() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedulesToDelete: Schedules = [
            Schedule(day: .monday, hour: 8)!  // Monday 8 AM
        ]
        let remainingSchedules: Schedules = [
            Schedule(day: .friday, hour: 17)!  // Friday 5 PM
        ]
        mockClient.mockResponses[FeatureID.pcDevicesMacSchedules.id] = remainingSchedules

        // When
        let schedules = try await service.deleteDeviceSchedules(mac: mac, schedules: schedulesToDelete)

        // Then
        #expect(schedules.count == 1)
        #expect(schedules[0].scheduleID.dayOfWeek == .friday)
        #expect(schedules[0].scheduleID.hourOfDay == 17)
    }

    @Test("Delete device schedules async failure")
    func testDeleteDeviceSchedulesAsyncFailure() async throws {
        // Given
        let mac = "AA:BB:CC:DD:EE:FF"
        let schedules = [Schedule(scheduleID: ScheduleID(rawValue: 1)!)]
        mockClient.mockErrors["PcDevicesMacSchedules"] = LiveboxError.featureNotFound("PcDevicesMacSchedules")

        // When/Then
        do {
            _ = try await service.deleteDeviceSchedules(mac: mac, schedules: schedules)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "PcDevicesMacSchedules")
        }
    }

    @Test("Get device details async success")
    func testGetDeviceDetailsAsyncSuccess() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        let expectedDeviceDetails = TestHelpers.createTestDeviceDetails(
            physAddress: "AA:BB:CC:DD:EE:FF",
            hostName: "TestDevice",
            alias: "My Test Device"
        )
        mockClient.mockResponses[FeatureID.connectedDevicesMac.id] = expectedDeviceDetails

        // When
        let deviceDetails = try await service.getDeviceDetail(mac: deviceId)

        // Then
        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(deviceDetails.hostName == "TestDevice")
        #expect(deviceDetails.alias == "My Test Device")
    }

    @Test("Get device details async failure")
    func testGetDeviceDetailsAsyncFailure() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        mockClient.mockErrors["ConnectedDevicesMac"] = LiveboxError.featureNotFound("ConnectedDevicesMac")

        // When/Then
        do {
            _ = try await service.getDeviceDetail(mac: deviceId)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "ConnectedDevicesMac")
        }
    }

    @Test("Set device alias async success")
    func testSetDeviceAliasAsyncSuccess() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        let newAlias = "My Smart Device"
        let expectedDeviceDetails = TestHelpers.createTestDeviceDetails(
            physAddress: "AA:BB:CC:DD:EE:FF",
            alias: newAlias
        )
        mockClient.mockResponses[FeatureID.connectedDevicesMac.id] = expectedDeviceDetails

        // When
        let deviceDetails = try await service.setDeviceAlias(mac: deviceId, alias: newAlias)

        // Then
        #expect(deviceDetails.alias == newAlias)
        #expect(deviceDetails.physAddress == "AA:BB:CC:DD:EE:FF")
    }

    @Test("Set device alias async failure")
    func testSetDeviceAliasAsyncFailure() async throws {
        // Given
        let deviceId = "AABBCCDDEEFF"
        let newAlias = "My Smart Device"
        mockClient.mockErrors["ConnectedDevicesMac"] = LiveboxError.featureNotFound("ConnectedDevicesMac")

        // When/Then
        do {
            _ = try await service.setDeviceAlias(mac: deviceId, alias: newAlias)
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "ConnectedDevicesMac")
        }
    }

    @Test("Get connected devices async success")
    func testGetConnectedDevicesAsyncSuccess() async throws {
        // Given
        let expectedDevices = [
            TestHelpers.createTestDevice(physAddress: "AA:BB:CC:DD:EE:FF", hostName: "Device1", active: true),
            TestHelpers.createTestDevice(physAddress: "11:22:33:44:55:66", hostName: "Device2", active: false),
        ]
        mockClient.mockResponses[FeatureID.connectedDevices.id] = expectedDevices

        // When
        let devices = try await service.getConnectedDevices()

        // Then
        #expect(devices.count == 2)
        #expect(devices[0].physAddress == "AA:BB:CC:DD:EE:FF")
        #expect(devices[0].active == true)
        #expect(devices[1].physAddress == "11:22:33:44:55:66")
        #expect(devices[1].active == false)
    }

    @Test("Get connected devices async failure")
    func testGetConnectedDevicesAsyncFailure() async throws {
        // Given
        mockClient.mockErrors["ConnectedDevices"] = LiveboxError.featureNotFound("ConnectedDevices")

        // When/Then
        do {
            _ = try await service.getConnectedDevices()
            Issue.record("Expected failure but got success")
        } catch .featureNotFound(let message) {
            #expect(message == "ConnectedDevices")
        }
    }
}
