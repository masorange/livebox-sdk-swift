import Foundation
import os.log

/// Log levels matching OSLogType for consistent logging behavior.
public enum LiveboxLogLevel: String, CaseIterable {
    case debug
    case info
    case `default`
    case error
    case fault

    /// Converts to OSLogType for compatibility with OSLog.
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .default: return .default
        case .error: return .error
        case .fault: return .fault
        }
    }

    /// Priority value for level comparison (higher = more important).
    internal var priority: Int {
        switch self {
        case .debug: return 0
        case .info: return 1
        case .default: return 2
        case .error: return 3
        case .fault: return 4
        }
    }
}

/// Metrics data for HTTP requests.
public struct HTTPMetrics {
    /// The time when the request started.
    public let requestStartTime: CFAbsoluteTime
    /// The time when the response was received (or error occurred).
    public let responseTime: CFAbsoluteTime
    /// The total duration of the request in seconds.
    public var duration: TimeInterval { responseTime - requestStartTime }
    /// The HTTP status code, if available.
    public let statusCode: Int?
    /// The size of the request body in bytes.
    public let requestBodySize: Int
    /// The size of the response body in bytes.
    public let responseBodySize: Int
    /// Whether the request resulted in an error.
    public let hadError: Bool
}

/// Protocol for custom logging implementations in Livebox.
/// Developers can implement this protocol to provide their own logging behavior.
public protocol LiveboxLogger {
    /// Logs an HTTP request.
    /// - Parameters:
    ///   - request: The URLRequest being made
    ///   - body: The request body data, if any
    ///   - level: The log level for this request
    func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel)

    /// Logs an HTTP response.
    /// - Parameters:
    ///   - response: The HTTPURLResponse received
    ///   - data: The response data, if any
    ///   - error: Any error that occurred, if applicable
    ///   - level: The log level for this response
    ///   - metrics: Performance metrics for the request/response cycle
    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics)
}

/// Extended protocol for loggers that want to handle metrics separately.
public protocol LiveboxMetricsLogger: LiveboxLogger {
    /// Logs metrics data for HTTP requests.
    /// - Parameters:
    ///   - metrics: The metrics data for the completed request
    ///   - level: The log level for the metrics
    func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel)
}

/// Default implementations for backward compatibility.
extension LiveboxLogger {
    /// Default implementation that calls the new method with .info level.
    public func logRequest(_ request: URLRequest, body: Data?) {
        logRequest(request, body: body, level: .info)
    }

    /// Default implementation that calls the new method with appropriate level.
    public func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?) {
        let level: LiveboxLogLevel = error != nil ? .error : .info
        let metrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent(),
            responseTime: CFAbsoluteTimeGetCurrent(),
            statusCode: response?.statusCode,
            requestBodySize: 0,
            responseBodySize: data?.count ?? 0,
            hadError: error != nil
        )
        logResponse(response, data: data, error: error, level: level, metrics: metrics)
    }
}

/// Default logger implementation using OSLog.
/// This logger provides structured logging with appropriate categories and levels.
public final class DefaultLiveboxLogger: LiveboxLogger, LiveboxMetricsLogger {

    private let osLog: OSLog
    private let metricsLog: OSLog
    private let subsystem: String

    /// Creates a new DefaultLiveboxLogger instance.
    /// - Parameter subsystem: The subsystem identifier for logging. Defaults to the bundle identifier.
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.masorange.livebox") {
        self.subsystem = subsystem
        self.osLog = OSLog(subsystem: subsystem, category: "LiveboxHTTP")
        self.metricsLog = OSLog(subsystem: subsystem, category: "LiveboxMetrics")
    }

    /// Checks if a message should be logged based on the current minimum log level.
    private func shouldLog(level: LiveboxLogLevel) -> Bool {
        return level.priority >= LiveboxConfiguration.shared.minimumLogLevel.priority
    }

    public func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        guard shouldLog(level: level) else { return }

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "UNKNOWN_URL"

        var logMessage = "🚀 HTTP REQUEST: \(method) \(url)"

        // Log headers (excluding sensitive information)
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            let sanitizedHeaders = sanitizeHeaders(headers)
            logMessage += "\n   Headers: \(sanitizedHeaders)"
        }

        // Log body if present (with size limit for readability)
        if let body = body {
            logMessage += "\n   Body Size: \(body.count) bytes"
            if body.count < 1024, let bodyString = String(data: body, encoding: .utf8) {
                logMessage += "\n   Body: \(bodyString)"
            }
        }

        self.logMessage(logMessage, level: level, log: osLog)
    }

    public func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        guard shouldLog(level: level) else { return }

        if let error = error {
            let errorMessage = "❌ HTTP ERROR: \(error.localizedDescription)"
            logMessage(errorMessage, level: level, log: osLog)
            return
        }

        guard let response = response else {
            let errorMessage = "❌ HTTP ERROR: No response received"
            logMessage(errorMessage, level: .error, log: osLog)
            return
        }

        let statusCode = response.statusCode
        let statusEmoji = statusCode < 400 ? "✅" : "❌"
        let url = response.url?.absoluteString ?? "UNKNOWN_URL"

        var logMessage = "\(statusEmoji) HTTP RESPONSE: \(statusCode) \(url)"
        logMessage += "\n   Duration: \(String(format: "%.3f", metrics.duration))s"

        // Log response data (with size limit for readability)
        if let data = data {
            let formatter = ByteCountFormatter()
            let responseSize = formatter.string(fromByteCount: Int64(data.count))
            logMessage += "\n   Response Size: \(responseSize)"

            if data.count < 1024, let responseString = String(data: data, encoding: .utf8) {
                logMessage += "\n   Response: \(responseString)"
            }
        }

        self.logMessage(logMessage, level: level, log: osLog)

        // Log metrics separately if enabled
        if LiveboxConfiguration.shared.metricsLoggingEnabled {
            logMetrics(metrics, level: .debug)
        }
    }

    public func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        guard LiveboxConfiguration.shared.metricsLoggingEnabled && shouldLog(level: level) else { return }

        let metricsMessage = """
            📊 HTTP METRICS:
               Duration: \(String(format: "%.3f", metrics.duration))s
               Status: \(metrics.statusCode?.description ?? "N/A")
               Request Size: \(metrics.requestBodySize) bytes
               Response Size: \(metrics.responseBodySize) bytes
               Error: \(metrics.hadError ? "Yes" : "No")
            """

        logMessage(metricsMessage, level: level, log: metricsLog)
    }

    /// Helper method to log messages with the appropriate level and compatibility.
    private func logMessage(_ message: String, level: LiveboxLogLevel, log: OSLog) {
        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = os.Logger(log)
            switch level {
            case .debug:
                logger.debug("\(message)")
            case .info:
                logger.info("\(message)")
            case .default:
                logger.log("\(message)")
            case .error:
                logger.error("\(message)")
            case .fault:
                logger.fault("\(message)")
            }
        } else {
            os_log("%{public}@", log: log, type: level.osLogType, message)
        }
    }

    /// Sanitizes headers by removing or masking sensitive information.
    /// - Parameter headers: The original headers dictionary
    /// - Returns: Sanitized headers dictionary
    private func sanitizeHeaders(_ headers: [String: String]) -> [String: String] {
        return headers.mapValues { value in
            // Mask authorization headers for security
            if headers.keys.contains(where: { $0.lowercased() == "authorization" }) {
                return "***MASKED***"
            }
            return value
        }
    }
}

/// Silent logger that doesn't log anything.
/// Useful when logging should be completely disabled.
public final class SilentLiveboxLogger: LiveboxLogger, LiveboxMetricsLogger {

    public init() {}

    public func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        // Intentionally empty - no logging
    }

    public func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        // Intentionally empty - no logging
    }

    public func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        // Intentionally empty - no logging
    }
}
