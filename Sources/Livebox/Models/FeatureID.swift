import Foundation

/// A type-safe identifier for router features.
/// This enum provides compile-time safety when referencing features,
/// preventing typos and enabling autocompletion.
public enum FeatureID: String, CaseIterable {
    // MARK: - General Information
    case capabilities = "Capabilities"
    case generalInfo = "GeneralInfo"
    case reboot = "Reboot"
    case reset = "Reset"
    case fullReset = "FullReset"
    case fwUpgrade = "FwUpgrade"
    case autoreboot = "Autoreboot"

    // MARK: - WAN
    case wan = "Wan"
    case wanSupported = "WanSupported"
    case dsl = "Dsl"
    case dslStats = "DslStats"
    case threeG = "3g"
    case threeGNetwork = "3gNetwork"
    case threeGPin = "3gPin"
    case threeGPuk = "3gPuk"
    case ont = "Ont"
    case ontAlarms = "OntAlarms"
    case ontGem = "OntGem"
    case ontGtc = "OntGtc"
    case ppp = "Ppp"
    case pppRestart = "PppRestart"
    case wanDhcp = "WanDhcp"
    case wanDhcpRenew = "WanDhcpRenew"
    case wanDhcpv6 = "WanDhcpv6"
    case wanDhcpv6Renew = "WanDhcpv6Renew"

    // MARK: - WiFi
    case wifiSupported = "WifiSupported"
    case wifi = "Wifi"
    case smartWifi = "SmartWifi"
    case wlanInterface = "WlanInterface"
    case wlanSupported = "WlanSupported"
    case wlanAccessPoint = "WlanAccessPoint"
    case wlanSecurity = "WlanSecurity"
    case wlanWPS = "WlanWPS"
    case wlanWpsStartPairing = "WlanWpsStartPairing"
    case wlanMacFiltering = "WlanMacFiltering"
    case wlanMacFilteringMac = "WlanMacFilteringMac"
    case wlanSchedule = "WlanSchedule"
    case wlanScheduleEnable = "WlanScheduleEnable"
    case wlanScheduleId = "WlanScheduleId"
    case wlanScheduleDelById = "WlanScheduleDelById"
    case wlanScheduleTempSwitchOn = "WlanScheduleTempSwitchOn"
    case scanChannel = "ScanChannel"

    // MARK: - LAN & DHCP
    case lanDhcp = "LanDhcp"
    case lanDhcpFixedIp = "LanDhcpFixedIp"
    case lanDhcpFixedIpId = "LanDhcpFixedIpId"
    case connectedDevices = "ConnectedDevices"
    case connectedDevicesMac = "ConnectedDevicesMac"
    case deviceList = "DeviceList"

    // MARK: - Connectivity
    case connectivity = "Connectivity"
    case ethPort = "EthPort"
    case ethPortId = "EthPortId"
    case usbPort = "UsbPort"
    case usbPortId = "UsbPortId"
    case usbPortIdEject = "UsbPortIdEject"
    case fxsPort = "FxsPort"

    // MARK: - VoIP
    case voIP = "VoIP"
    case sip = "SIP"
    case sipLines = "SipLines"
    case sipLinesLine = "SipLinesLine"
    case sipSubscription = "SipSuscription"
    case h323 = "H323"
    case h323Lines = "H323Lines"
    case h323LinesLine = "H323LinesLine"
    case softphone = "Softphone"
    case softphonePairedClients = "SoftphonePairedClients"
    case autodial = "Autodial"
    case ring = "Ring"
    case callRegistry = "CallRegistry"

    // MARK: - Services
    case ddns = "DDNS"
    case ddnsProviders = "DdnsProviders"
    case parentalCtrl = "ParentalCtrl"
    case pcUrls = "PcUrls"
    case pcUrlsId = "PcUrlsId"
    case parentalCtrlUrls = "ParentalCtrlUrls"
    case pcDevices = "PcDevices"
    case pcDevicesMac = "PcDevicesMac"
    case pcDevicesMacUrls = "PcDevicesMacUrls"
    case pcDevicesMacUrlsId = "PcDevicesMacUrlsId"
    case pcDevicesMacServices = "PcDevicesMacServices"
    case pcDevicesMacServicesId = "PcDevicesMacServicesId"
    case pcDevicesMacSchedules = "PcDevicesMacSchedules"
    case pcDevicesMacSchedulesId = "PcDevicesMacSchedulesId"
    case firewall = "Firewall"
    case firewallServices = "FirewallServices"
    case firewallServicesId = "FirewallServicesId"
    case nat = "NAT"
    case ipNat = "IpNat"
    case ipNatId = "IpNatId"
    case portNat = "PortNat"
    case portNatId = "PortNatId"
    case notifications = "Notifications"
    case notificationsEmail = "NotificationsEmail"
    case qos = "Qos"
    case qosSupported = "QosSupported"
    case qosRun = "QosRun"

    // MARK: - Access Control
    case access = "Access"
    case accessLanGui = "AccessLanGui"
    case accessWanGui = "AccessWanGui"
    case accessWanGuiAllow = "AccessWanGuiAllow"
    case accessOpenApi = "AccessOpenApi"
    case accessLanApi = "AccessLanApi"
    case accessWanApi = "AccessWanApi"
    case accessOspApi = "AccessOspApi"

    // MARK: - Reporting
    case report = "Report"
    case reportDispatch = "ReportDispatch"
}

extension FeatureID {
    /// The string identifier used in API calls.
    public var id: String {
        return rawValue
    }

    /// A human-readable description of the feature.
    public var description: String {
        switch self {
        case .capabilities:
            return "Router capabilities"
        case .generalInfo:
            return "General router information"
        case .reboot:
            return "Reboot the router"
        case .reset:
            return "Reset router configuration"
        case .fullReset:
            return "Factory reset the router"
        case .fwUpgrade:
            return "Firmware upgrade"
        case .autoreboot:
            return "Automatic reboot configuration"
        case .wan:
            return "WAN configuration"
        case .wanSupported:
            return "Supported WAN features"
        case .dsl:
            return "DSL configuration"
        case .dslStats:
            return "DSL statistics"
        case .threeG:
            return "3G configuration"
        case .threeGNetwork:
            return "3G network settings"
        case .threeGPin:
            return "3G PIN management"
        case .threeGPuk:
            return "3G PUK management"
        case .ont:
            return "ONT configuration"
        case .ontAlarms:
            return "ONT alarms"
        case .ontGem:
            return "ONT GEM statistics"
        case .ontGtc:
            return "ONT GTC statistics"
        case .ppp:
            return "PPP configuration"
        case .pppRestart:
            return "Restart PPP connection"
        case .wanDhcp:
            return "WAN DHCP configuration"
        case .wanDhcpRenew:
            return "Renew WAN DHCP lease"
        case .wanDhcpv6:
            return "WAN DHCPv6 configuration"
        case .wanDhcpv6Renew:
            return "Renew WAN DHCPv6 lease"
        case .wifiSupported:
            return "Supported WiFi features"
        case .wifi:
            return "WiFi interfaces"
        case .smartWifi:
            return "Smart WiFi configuration"
        case .wlanInterface:
            return "WLAN interface configuration"
        case .wlanSupported:
            return "Supported WLAN features"
        case .wlanAccessPoint:
            return "WLAN access point configuration"
        case .wlanSecurity:
            return "WLAN security settings"
        case .wlanWPS:
            return "WLAN WPS configuration"
        case .wlanWpsStartPairing:
            return "Start WLAN WPS pairing"
        case .wlanMacFiltering:
            return "WLAN MAC filtering"
        case .wlanMacFilteringMac:
            return "WLAN MAC filtering entry"
        case .wlanSchedule:
            return "WLAN scheduling"
        case .wlanScheduleEnable:
            return "Enable WLAN scheduling"
        case .wlanScheduleId:
            return "WLAN schedule entry"
        case .wlanScheduleDelById:
            return "Delete WLAN schedule by ID"
        case .wlanScheduleTempSwitchOn:
            return "Temporarily switch on WLAN"
        case .scanChannel:
            return "Scan WiFi channels"
        case .lanDhcp:
            return "LAN DHCP configuration"
        case .lanDhcpFixedIp:
            return "DHCP fixed IP addresses"
        case .lanDhcpFixedIpId:
            return "DHCP fixed IP address entry"
        case .connectedDevices:
            return "Connected devices"
        case .connectedDevicesMac:
            return "Connected device details"
        case .deviceList:
            return "Device list"
        case .connectivity:
            return "Connectivity status"
        case .ethPort:
            return "Ethernet ports"
        case .ethPortId:
            return "Ethernet port configuration"
        case .usbPort:
            return "USB ports"
        case .usbPortId:
            return "USB port details"
        case .usbPortIdEject:
            return "Eject USB device"
        case .fxsPort:
            return "FXS ports"
        case .voIP:
            return "VoIP configuration"
        case .sip:
            return "SIP configuration"
        case .sipLines:
            return "SIP lines"
        case .sipLinesLine:
            return "SIP line configuration"
        case .sipSubscription:
            return "SIP subscription"
        case .h323:
            return "H.323 configuration"
        case .h323Lines:
            return "H.323 lines"
        case .h323LinesLine:
            return "H.323 line configuration"
        case .softphone:
            return "Softphone configuration"
        case .softphonePairedClients:
            return "Softphone paired clients"
        case .autodial:
            return "Autodial configuration"
        case .ring:
            return "Ring phone"
        case .callRegistry:
            return "Call registry"
        case .ddns:
            return "Dynamic DNS configuration"
        case .ddnsProviders:
            return "Available DDNS providers"
        case .pcUrls, .parentalCtrl:
            return "Parental control"
        case .pcUrlsId:
            return "Parental control URL entry"
        case .parentalCtrlUrls:
            return "Parental control URLs"
        case .pcDevices:
            return "Parental control devices"
        case .pcDevicesMac:
            return "Parental control device settings"
        case .pcDevicesMacUrls:
            return "Parental control device URLs"
        case .pcDevicesMacUrlsId:
            return "Parental control device URL entry"
        case .pcDevicesMacServices:
            return "Parental control device services"
        case .pcDevicesMacServicesId:
            return "Parental control device service entry"
        case .pcDevicesMacSchedules:
            return "Parental control device schedules"
        case .pcDevicesMacSchedulesId:
            return "Parental control device schedule entry"
        case .firewall:
            return "Firewall configuration"
        case .firewallServices:
            return "Firewall services"
        case .firewallServicesId:
            return "Firewall service entry"
        case .nat:
            return "NAT configuration"
        case .ipNat:
            return "IP NAT rules"
        case .ipNatId:
            return "IP NAT rule entry"
        case .portNat:
            return "Port NAT rules"
        case .portNatId:
            return "Port NAT rule entry"
        case .notifications:
            return "Notification settings"
        case .notificationsEmail:
            return "Email notification settings"
        case .qos:
            return "Quality of Service"
        case .qosSupported:
            return "Supported QoS features"
        case .qosRun:
            return "Run QoS analysis"
        case .access:
            return "Access control"
        case .accessLanGui:
            return "LAN GUI access control"
        case .accessWanGui:
            return "WAN GUI access control"
        case .accessWanGuiAllow:
            return "Allow WAN GUI access"
        case .accessOpenApi:
            return "Open API access control"
        case .accessLanApi:
            return "LAN API access control"
        case .accessWanApi:
            return "WAN API access control"
        case .accessOspApi:
            return "OSP API access control"
        case .report:
            return "System reports"
        case .reportDispatch:
            return "Dispatch system report"
        }
    }

    /// Features commonly used for device management.
    public static let deviceManagement: [FeatureID] = [
        .connectedDevices,
        .connectedDevicesMac,
        .deviceList,
        .pcDevicesMac,
        .pcDevicesMacSchedules,
        .pcDevicesMacServices,
    ]

    /// Features related to WiFi configuration.
    public static let wifiFeatures: [FeatureID] = [
        .wifi,
        .wifiSupported,
        .smartWifi,
        .wlanInterface,
        .wlanAccessPoint,
        .wlanSecurity,
        .wlanWPS,
        .wlanMacFiltering,
        .wlanSchedule,
        .scanChannel,
    ]

    /// Features related to WAN connectivity.
    public static let wanFeatures: [FeatureID] = [
        .wan,
        .wanSupported,
        .dsl,
        .dslStats,
        .ppp,
        .wanDhcp,
        .wanDhcpv6,
    ]

    /// Features that support the invoke operation.
    public static let invokeFeatures: [FeatureID] = [
        .reboot,
        .reset,
        .fullReset,
        .fwUpgrade,
        .pppRestart,
        .wanDhcpRenew,
        .wanDhcpv6Renew,
        .wlanWpsStartPairing,
        .wlanScheduleTempSwitchOn,
        .wlanScheduleDelById,
        .usbPortIdEject,
        .ring,
        .qosRun,
        .accessWanGuiAllow,
        .reportDispatch,
    ]
}
