import Foundation

/// A type-safe identifier for router features.
///
/// Each case matches the `Id` of a feature in the router's ``Capabilities``.
/// A router only supports the features listed in its capabilities.
public enum FeatureID: String, CaseIterable {
    // MARK: - General Information
    /// Router capabilities.
    case capabilities = "Capabilities"
    /// General router information.
    case generalInfo = "GeneralInfo"
    /// Reboot the router.
    case reboot = "Reboot"
    /// Reset router configuration.
    case reset = "Reset"
    /// Factory reset the router.
    case fullReset = "FullReset"
    /// Firmware upgrade.
    case fwUpgrade = "FwUpgrade"
    /// Automatic reboot configuration.
    case autoreboot = "Autoreboot"

    // MARK: - WAN
    /// WAN configuration.
    case wan = "Wan"
    /// Supported WAN features.
    case wanSupported = "WanSupported"
    /// DSL configuration.
    case dsl = "Dsl"
    /// DSL statistics.
    case dslStats = "DslStats"
    /// 3G configuration.
    case threeG = "3g"
    /// 3G network settings.
    case threeGNetwork = "3gNetwork"
    /// 3G PIN management.
    case threeGPin = "3gPin"
    /// 3G PUK management.
    case threeGPuk = "3gPuk"
    /// ONT configuration.
    case ont = "Ont"
    /// ONT alarms.
    case ontAlarms = "OntAlarms"
    /// ONT GEM statistics.
    case ontGem = "OntGem"
    /// ONT GTC statistics.
    case ontGtc = "OntGtc"
    /// PPP configuration.
    case ppp = "Ppp"
    /// Restart PPP connection.
    case pppRestart = "PppRestart"
    /// WAN DHCP configuration.
    case wanDhcp = "WanDhcp"
    /// Renew WAN DHCP lease.
    case wanDhcpRenew = "WanDhcpRenew"
    /// WAN DHCPv6 configuration.
    case wanDhcpv6 = "WanDhcpv6"
    /// Renew WAN DHCPv6 lease.
    case wanDhcpv6Renew = "WanDhcpv6Renew"

    // MARK: - WiFi
    /// Supported WiFi features.
    case wifiSupported = "WifiSupported"
    /// WiFi interfaces.
    case wifi = "Wifi"
    /// Smart WiFi configuration.
    case smartWifi = "SmartWifi"
    /// WLAN interface configuration.
    case wlanInterface = "WlanInterface"
    /// Supported WLAN features.
    case wlanSupported = "WlanSupported"
    /// WLAN access point configuration.
    case wlanAccessPoint = "WlanAccessPoint"
    /// WLAN security settings.
    case wlanSecurity = "WlanSecurity"
    /// WLAN WPS configuration.
    case wlanWPS = "WlanWPS"
    /// Start WLAN WPS pairing.
    case wlanWpsStartPairing = "WlanWpsStartPairing"
    /// WLAN MAC filtering.
    case wlanMacFiltering = "WlanMacFiltering"
    /// WLAN MAC filtering entry.
    case wlanMacFilteringMac = "WlanMacFilteringMac"
    /// WLAN scheduling.
    case wlanSchedule = "WlanSchedule"
    /// Enable WLAN scheduling.
    case wlanScheduleEnable = "WlanScheduleEnable"
    /// WLAN schedule entry.
    case wlanScheduleId = "WlanScheduleId"
    /// Delete WLAN schedule by ID.
    case wlanScheduleDelById = "WlanScheduleDelById"
    /// Temporarily switch on WLAN.
    case wlanScheduleTempSwitchOn = "WlanScheduleTempSwitchOn"
    /// Scan WiFi channels.
    case scanChannel = "ScanChannel"

    // MARK: - LAN & DHCP
    /// LAN DHCP configuration.
    case lanDhcp = "LanDhcp"
    /// DHCP fixed IP addresses.
    case lanDhcpFixedIp = "LanDhcpFixedIp"
    /// DHCP fixed IP address entry.
    case lanDhcpFixedIpId = "LanDhcpFixedIpId"
    /// Connected devices.
    case connectedDevices = "ConnectedDevices"
    /// Connected device details.
    case connectedDevicesMac = "ConnectedDevicesMac"
    /// Device list.
    case deviceList = "DeviceList"

    // MARK: - Connectivity
    /// Connectivity status.
    case connectivity = "Connectivity"
    /// Ethernet ports.
    case ethPort = "EthPort"
    /// Ethernet port configuration.
    case ethPortId = "EthPortId"
    /// USB ports.
    case usbPort = "UsbPort"
    /// USB port details.
    case usbPortId = "UsbPortId"
    /// Eject USB device.
    case usbPortIdEject = "UsbPortIdEject"
    /// FXS ports.
    case fxsPort = "FxsPort"

    // MARK: - VoIP
    /// VoIP configuration.
    case voIP = "VoIP"
    /// SIP configuration.
    case sip = "SIP"
    /// SIP lines.
    case sipLines = "SipLines"
    /// SIP line configuration.
    case sipLinesLine = "SipLinesLine"
    /// SIP subscription.
    ///
    /// The raw value, `SipSuscription`, matches the one sent by the router.
    case sipSubscription = "SipSuscription"
    /// H.323 configuration.
    case h323 = "H323"
    /// H.323 lines.
    case h323Lines = "H323Lines"
    /// H.323 line configuration.
    case h323LinesLine = "H323LinesLine"
    /// Softphone configuration.
    case softphone = "Softphone"
    /// Softphone paired clients.
    case softphonePairedClients = "SoftphonePairedClients"
    /// Autodial configuration.
    case autodial = "Autodial"
    /// Ring phone.
    case ring = "Ring"
    /// Call registry.
    case callRegistry = "CallRegistry"

    // MARK: - Services
    /// Dynamic DNS configuration.
    case ddns = "DDNS"
    /// Available DDNS providers.
    case ddnsProviders = "DdnsProviders"
    /// Parental control.
    case parentalCtrl = "ParentalCtrl"
    /// Parental control URLs.
    case pcUrls = "PcUrls"
    /// Parental control URL entry.
    case pcUrlsId = "PcUrlsId"
    /// Parental control URLs.
    case parentalCtrlUrls = "ParentalCtrlUrls"
    /// Parental control devices.
    case pcDevices = "PcDevices"
    /// Parental control device settings.
    case pcDevicesMac = "PcDevicesMac"
    /// Parental control device URLs.
    case pcDevicesMacUrls = "PcDevicesMacUrls"
    /// Parental control device URL entry.
    case pcDevicesMacUrlsId = "PcDevicesMacUrlsId"
    /// Parental control device services.
    case pcDevicesMacServices = "PcDevicesMacServices"
    /// Parental control device service entry.
    case pcDevicesMacServicesId = "PcDevicesMacServicesId"
    /// Parental control device schedules.
    case pcDevicesMacSchedules = "PcDevicesMacSchedules"
    /// Parental control device schedule entry.
    case pcDevicesMacSchedulesId = "PcDevicesMacSchedulesId"
    /// Firewall configuration.
    case firewall = "Firewall"
    /// Firewall services.
    case firewallServices = "FirewallServices"
    /// Firewall service entry.
    case firewallServicesId = "FirewallServicesId"
    /// NAT configuration.
    case nat = "NAT"
    /// IP NAT rules.
    case ipNat = "IpNat"
    /// IP NAT rule entry.
    case ipNatId = "IpNatId"
    /// Port NAT rules.
    case portNat = "PortNat"
    /// Port NAT rule entry.
    case portNatId = "PortNatId"
    /// Notification settings.
    case notifications = "Notifications"
    /// Email notification settings.
    case notificationsEmail = "NotificationsEmail"
    /// Quality of Service.
    case qos = "Qos"
    /// Supported QoS features.
    case qosSupported = "QosSupported"
    /// Run QoS analysis.
    case qosRun = "QosRun"

    // MARK: - Access Control
    /// Access control.
    case access = "Access"
    /// LAN GUI access control.
    case accessLanGui = "AccessLanGui"
    /// WAN GUI access control.
    case accessWanGui = "AccessWanGui"
    /// Allow WAN GUI access.
    case accessWanGuiAllow = "AccessWanGuiAllow"
    /// Open API access control.
    case accessOpenApi = "AccessOpenApi"
    /// LAN API access control.
    case accessLanApi = "AccessLanApi"
    /// WAN API access control.
    case accessWanApi = "AccessWanApi"
    /// OSP API access control.
    case accessOspApi = "AccessOspApi"

    // MARK: - Reporting
    /// System reports.
    case report = "Report"
    /// Dispatch system report.
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
        case .parentalCtrl:
            return "Parental control"
        case .pcUrls:
            return "Parental control URLs"
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
