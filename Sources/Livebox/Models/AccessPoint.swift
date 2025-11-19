public struct AccessPoint: Codable {
    public let idx: String?
    public let bssid: String
    public let type: AccessPointType
    public let manner: Manner
    public var status: Status
    public var ssid: String
    public var password: String
    public var ssidAdvertisementEnabled: Bool?
    @FlexibleInt public var retryLimit: Int?
    public let wmmCapability: Bool?
    public let uapsdCapability: Bool?
    public var wmmEnable: Bool?
    public var uapsdEnable: Bool?
    @FlexibleInt public var maxStations: Int?
    public var apBridgeDisable: Bool?
    public var channelConf: ChannelConf
    @FlexibleInt public var channel: Int?
    public var bandwidthConf: BandwidthConf
    public let bandwidth: String
    public var mode: String?
    public let schedulingAllowed: Bool

    private enum CodingKeys: String, CodingKey {
        case idx = "idx"
        case idxAlt = "Idx"  // ZTE router variant
        case bssid = "BSSID"
        case type = "Type"
        case manner = "Manner"
        case status = "Status"
        case ssid = "SSID"
        case password = "Password"
        case ssidAdvertisementEnabled = "SSIDAdvertisementEnabled"
        case retryLimit = "RetryLimit"
        case wmmCapability = "WMMCapability"
        case uapsdCapability = "UAPSDCapability"
        case wmmEnable = "WMMEnable"
        case uapsdEnable = "UAPSDEnable"
        case maxStations = "MaxStations"
        case apBridgeDisable = "APBridgeDisable"
        case channelConf = "ChannelConf"
        case channel = "Channel"
        case bandwidthConf = "BandwithConf"
        case bandwidth = "Bandwith"
        case mode = "Mode"
        case schedulingAllowed = "SchedulingAllowed"
    }

    public init(
        idx: String? = nil,
        bssid: String,
        type: AccessPointType,
        manner: Manner,
        status: Status,
        ssid: String,
        password: String,
        ssidAdvertisementEnabled: Bool? = nil,
        retryLimit: Int? = nil,
        wmmCapability: Bool? = nil,
        uapsdCapability: Bool? = nil,
        wmmEnable: Bool? = nil,
        uapsdEnable: Bool? = nil,
        maxStations: Int? = nil,
        apBridgeDisable: Bool? = nil,
        channelConf: ChannelConf,
        channel: Int,
        bandwidthConf: BandwidthConf,
        bandwidth: String,
        mode: String? = nil,
        schedulingAllowed: Bool
    ) {
        self.idx = idx
        self.bssid = bssid
        self.type = type
        self.manner = manner
        self.status = status
        self.ssid = ssid
        self.password = password
        self.ssidAdvertisementEnabled = ssidAdvertisementEnabled
        self.retryLimit = retryLimit
        self.wmmCapability = wmmCapability
        self.uapsdCapability = uapsdCapability
        self.wmmEnable = wmmEnable
        self.uapsdEnable = uapsdEnable
        self.maxStations = maxStations
        self.apBridgeDisable = apBridgeDisable
        self.channelConf = channelConf
        self.channel = channel
        self.bandwidthConf = bandwidthConf
        self.bandwidth = bandwidth
        self.mode = mode
        self.schedulingAllowed = schedulingAllowed
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Handle idx field that may come as "idx" or "Idx" (ZTE routers)
        self.idx = container.decodeIfPresent(String.self, forFirstOf: .idx, .idxAlt)

        self.bssid = try container.decode(String.self, forKey: .bssid)
        self.type = try container.decode(AccessPointType.self, forKey: .type)
        self.manner = try container.decode(Manner.self, forKey: .manner)
        self.status = try container.decode(Status.self, forKey: .status)
        self.ssid = try container.decode(String.self, forKey: .ssid)
        self.password = try container.decode(String.self, forKey: .password)
        self.ssidAdvertisementEnabled = try container.decodeIfPresent(Bool.self, forKey: .ssidAdvertisementEnabled)

        self._retryLimit = try container.decodeIfPresent(FlexibleInt.self, forKey: .retryLimit) ?? FlexibleInt(wrappedValue: nil)

        self.wmmCapability = try container.decodeIfPresent(Bool.self, forKey: .wmmCapability)
        self.uapsdCapability = try container.decodeIfPresent(Bool.self, forKey: .uapsdCapability)
        self.wmmEnable = try container.decodeIfPresent(Bool.self, forKey: .wmmEnable)
        self.uapsdEnable = try container.decodeIfPresent(Bool.self, forKey: .uapsdEnable)

        self._maxStations = try container.decodeIfPresent(FlexibleInt.self, forKey: .maxStations) ?? FlexibleInt(wrappedValue: nil)

        self.apBridgeDisable = try container.decodeIfPresent(Bool.self, forKey: .apBridgeDisable)
        self.channelConf = try container.decode(ChannelConf.self, forKey: .channelConf)

        self._channel = try container.decodeIfPresent(FlexibleInt.self, forKey: .channel) ?? FlexibleInt(wrappedValue: nil)

        self.bandwidthConf = try container.decode(BandwidthConf.self, forKey: .bandwidthConf)
        self.bandwidth = try container.decode(String.self, forKey: .bandwidth)
        self.mode = try container.decodeIfPresent(String.self, forKey: .mode)
        self.schedulingAllowed = try container.decode(Bool.self, forKey: .schedulingAllowed)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(idx, forKey: .idx)
        try container.encode(bssid, forKey: .bssid)
        try container.encode(type, forKey: .type)
        try container.encode(manner, forKey: .manner)
        try container.encode(status, forKey: .status)
        try container.encode(ssid, forKey: .ssid)
        try container.encode(password, forKey: .password)
        try container.encodeIfPresent(ssidAdvertisementEnabled, forKey: .ssidAdvertisementEnabled)
        try container.encodeIfPresent(retryLimit, forKey: .retryLimit)
        try container.encodeIfPresent(wmmCapability, forKey: .wmmCapability)
        try container.encodeIfPresent(uapsdCapability, forKey: .uapsdCapability)
        try container.encodeIfPresent(wmmEnable, forKey: .wmmEnable)
        try container.encodeIfPresent(uapsdEnable, forKey: .uapsdEnable)
        try container.encodeIfPresent(maxStations, forKey: .maxStations)
        try container.encodeIfPresent(apBridgeDisable, forKey: .apBridgeDisable)
        try container.encode(channelConf, forKey: .channelConf)
        try container.encode(channel, forKey: .channel)
        try container.encode(bandwidthConf, forKey: .bandwidthConf)
        try container.encode(bandwidth, forKey: .bandwidth)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encode(schedulingAllowed, forKey: .schedulingAllowed)
    }
}

extension AccessPoint {
    public func copy(
        status: AccessPoint.Status? = nil,
        ssid: String? = nil,
        password: String? = nil,
        ssidAdvertisementEnabled: Bool? = nil,
        retryLimit: Int? = nil,
        wmmEnable: Bool? = nil,
        uapsdEnable: Bool? = nil,
        apBridgeDisable: Bool? = nil,
        channelConf: ChannelConf? = nil,
        bandwidthConf: BandwidthConf? = nil,
        mode: String? = nil
    ) -> AccessPoint {
        var updated = self

        if let status = status {
            updated.status = status
        }
        if let ssid = ssid {
            updated.ssid = ssid
        }
        if let password = password {
            updated.password = password
        }
        if let ssidAdvertisementEnabled = ssidAdvertisementEnabled {
            updated.ssidAdvertisementEnabled = ssidAdvertisementEnabled
        }
        if let retryLimit = retryLimit {
            updated.retryLimit = retryLimit
        }
        if let wmmEnable = wmmEnable {
            updated.wmmEnable = wmmEnable
        }
        if let uapsdEnable = uapsdEnable {
            updated.uapsdEnable = uapsdEnable
        }
        if let apBridgeDisable = apBridgeDisable {
            updated.apBridgeDisable = apBridgeDisable
        }
        if let channelConf = channelConf {
            updated.channelConf = channelConf
        }
        if let bandwidthConf = bandwidthConf {
            updated.bandwidthConf = bandwidthConf
        }
        if let mode = mode {
            updated.mode = mode
        }

        return updated
    }
}

extension AccessPoint {
    public enum AccessPointType: RawRepresentable, Codable {
        case home
        case guest
        case unknown(String)

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "home":
                self = .home
            case "guest":
                self = .guest
            default:
                self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .home:
                return "Home"
            case .guest:
                return "Guest"
            case .unknown(let value):
                return value
            }
        }
    }
}

extension AccessPoint {
    public enum Manner: String, Codable {
        case combined = "Combined"
        case split = "Split"

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "combined":
                self = .combined
            case "split":
                self = .split
            default:
                return nil
            }
        }
    }
}

extension AccessPoint {
    public enum Status: String, Codable {
        case up = "Up"
        case down = "Down"

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "up":
                self = .up
            case "down":
                self = .down
            default:
                return nil
            }
        }
    }
}

extension AccessPoint {
    public enum ChannelConf: String, Codable {
        case auto = "Auto"
        case auto1 = "Auto1"
        case auto2 = "Auto2"

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "auto":
                self = .auto
            case "auto1":
                self = .auto1
            case "auto2":
                self = .auto2
            default:
                return nil
            }
        }
    }
}

extension AccessPoint {
    public enum BandwidthConf: RawRepresentable, Codable {
        case auto
        case _20mhz
        case _40mhz
        case _80mhz
        case _160mhz
        case _20_40mhz
        case _80_40_20mhz
        case unknown(String)

        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "auto":
                self = .auto
            case "20mhz":
                self = ._20mhz
            case "40mhz":
                self = ._40mhz
            case "80mhz":
                self = ._80mhz
            case "160mhz":
                self = ._160mhz
            case "20/40mhz":
                self = ._20_40mhz
            case "80/40/20mhz":
                self = ._80_40_20mhz
            default:
                self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .auto:
                return "Auto"
            case ._20mhz:
                return "20MHz"
            case ._40mhz:
                return "40MHz"
            case ._80mhz:
                return "80MHz"
            case ._160mhz:
                return "160MHz"
            case ._20_40mhz:
                return "20/40MHz"
            case ._80_40_20mhz:
                return "80/40/20MHz"
            case .unknown(let value):
                return value
            }
        }
    }
}
