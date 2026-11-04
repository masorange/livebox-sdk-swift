import Foundation
import os.log

/// The importance of a log message, from least to most important.
///
/// The levels match the `OSLogType` values used by ``DefaultLiveboxLogger``.
public enum LiveboxLogLevel: String, CaseIterable {
    /// Detailed information. Used for performance metrics.
    case debug
    /// Regular activity. Used for requests and successful responses.
    case info
    /// Notable activity. Used for responses with a status code outside the 2xx, 4xx and 5xx ranges.
    case `default`
    /// Errors. Used for failed requests and HTTP 4xx responses.
    case error
    /// Faults. Used for HTTP 5xx responses.
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

/// Performance metrics of an HTTP request.
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

/// A type that logs the HTTP requests and responses made by the SDK.
///
/// Implement this protocol and pass it to ``LiveboxConfiguration/setLogger(_:)`` to use your own logging system.
/// Add ``LiveboxMetricsLogger`` conformance to also log performance metrics separately.
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

/// A logger that also logs the performance metrics of each request separately.
public protocol LiveboxMetricsLogger: LiveboxLogger {
    /// Logs metrics data for HTTP requests.
    /// - Parameters:
    ///   - metrics: The metrics data for the completed request
    ///   - level: The log level for the metrics
    func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel)
}

// Overloads without a log level, kept for backward compatibility.
extension LiveboxLogger {
    /// Logs an HTTP request at the ``LiveboxLogLevel/info`` level.
    /// - Parameters:
    ///   - request: The URLRequest being made
    ///   - body: The request body data, if any
    public func logRequest(_ request: URLRequest, body: Data?) {
        logRequest(request, body: body, level: .info)
    }

    /// Logs an HTTP response at the ``LiveboxLogLevel/error`` level if there is an error,
    /// or ``LiveboxLogLevel/info`` otherwise, with empty metrics.
    /// - Parameters:
    ///   - response: The HTTPURLResponse received
    ///   - data: The response data, if any
    ///   - error: Any error that occurred, if applicable
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

/// The default logger, which writes to OSLog.
///
/// Requests and responses are logged in the `LiveboxHTTP` category, and metrics in the `LiveboxMetrics` category.
/// Messages below ``LiveboxConfiguration/minimumLogLevel`` are discarded.
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

    /// Logs the method, URL and headers of a request, and its body if it's smaller than 1 KB.
    ///
    /// Sensitive headers, such as `Authorization`, are masked.
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

    /// Logs the status code, URL and duration of a response, and its body if it's smaller than 1 KB.
    ///
    /// If ``LiveboxConfiguration/metricsLoggingEnabled`` is `true`, it also logs the metrics at the ``LiveboxLogLevel/debug`` level.
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

    /// Logs the metrics of a request, if ``LiveboxConfiguration/metricsLoggingEnabled`` is `true`.
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

/// A logger that discards every message.
///
/// ``LiveboxConfiguration/disableLogging()-type.method`` sets this logger.
public final class SilentLiveboxLogger: LiveboxLogger, LiveboxMetricsLogger {

    /// Creates a silent logger.
    public init() {}

    /// Discards the request.
    public func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        // Intentionally empty - no logging
    }

    /// Discards the response.
    public func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        // Intentionally empty - no logging
    }

    /// Discards the metrics.
    public func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        // Intentionally empty - no logging
    }
}
