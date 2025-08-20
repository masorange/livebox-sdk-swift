import Foundation
import Livebox

/// Example demonstrating the various logging configurations available in Livebox.
/// This shows how developers can configure logging for HTTP requests and responses,
/// including log levels and performance metrics.
class LoggingExample {

    static func runExamples() {
        print("=== Livebox Logging Configuration Examples ===\n")

        // Example 1: Default logging (enabled by default)
        defaultLoggingExample()

        // Example 2: Disable logging
        disableLoggingExample()

        // Example 3: Custom logger with log levels and metrics
        customLoggerExample()

        // Example 4: Log level filtering
        logLevelFilteringExample()

        // Example 5: Metrics logging control
        metricsLoggingExample()

        // Example 6: Re-enable default logging
        reEnableDefaultLoggingExample()

        // Print current status
        LiveboxConfiguration.printCurrentLoggingStatus()
    }

    private static func defaultLoggingExample() {
        print("1. Default Logging (OSLog-based with log levels and metrics)")
        print("   Logging is enabled by default when you create a LiveboxAPI instance.")
        print("   All HTTP requests and responses will be logged using OSLog with appropriate levels.\n")

        // Default logging is already enabled, but you can explicitly enable it:
        LiveboxConfiguration.enableDefaultLogging()

        // Create API instance - logging will work automatically
        do {
            let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")
            print("   ✅ API created with default logging enabled")
            print("   📝 Check Console.app to see HTTP logs")
            print("   📊 Performance metrics are included by default\n")
        } catch {
            print("   ❌ Error creating API: \(error)\n")
        }
    }

    private static func disableLoggingExample() {
        print("2. Disable Logging")
        print("   You can completely disable logging for production or privacy concerns.\n")

        // Disable all logging
        LiveboxConfiguration.disableLogging()

        do {
            let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")
            print("   ✅ API created with logging disabled")
            print("   🔇 No HTTP requests or responses will be logged\n")
        } catch {
            print("   ❌ Error creating API: \(error)\n")
        }
    }

    private static func customLoggerExample() {
        print("3. Custom Logger with Log Levels and Metrics")
        print("   Implement your own logging behavior with support for log levels and performance metrics.\n")

        // Create and set a custom logger
        let customLogger = ExampleCustomLogger()
        LiveboxConfiguration.setLogger(customLogger)

        do {
            let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")
            print("   ✅ API created with custom logger")
            print("   📱 HTTP logs will use your custom implementation")
            print("   🎨 Logs will appear in a custom format below:\n")
        } catch {
            print("   ❌ Error creating API: \(error)\n")
        }
    }

    private static func logLevelFilteringExample() {
        print("4. Log Level Filtering")
        print("   Control which log levels are actually logged to reduce noise.\n")

        // Set minimum log level to error (filters out debug, info, default)
        LiveboxConfiguration.setMinimumLogLevel(.error)
        print("   🎛️  Minimum log level set to .error")
        print("   🔇 Debug, info, and default level logs will be filtered out")
        print("   ✅ Only error and fault level logs will appear\n")

        // Reset to debug to see all logs
        LiveboxConfiguration.setMinimumLogLevel(.debug)
        print("   🔄 Reset minimum log level to .debug for other examples\n")
    }

    private static func metricsLoggingExample() {
        print("5. Performance Metrics Logging")
        print("   Control whether performance metrics are logged separately.\n")

        // Disable metrics logging
        LiveboxConfiguration.setMetricsLogging(enabled: false)
        print("   📊 Metrics logging disabled")
        print("   📝 Only basic request/response logs will appear")
        print("   ⚡ Slightly better performance (no metrics calculations)\n")

        // Re-enable metrics logging
        LiveboxConfiguration.setMetricsLogging(enabled: true)
        print("   📊 Metrics logging re-enabled for other examples\n")
    }

    private static func reEnableDefaultLoggingExample() {
        print("6. Re-enable Default Logging")
        print("   You can switch back to default logging at any time.\n")

        // Re-enable default logging with custom subsystem
        LiveboxConfiguration.enableDefaultLogging(subsystem: "com.myapp.networking")

        do {
            let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")
            print("   ✅ API created with default logging re-enabled")
            print("   📝 Logs will appear in Console.app under 'com.myapp.networking' subsystem")
            print("   🎯 All log levels and metrics are enabled by default\n")
        } catch {
            print("   ❌ Error creating API: \(error)\n")
        }
    }
}

/// Example custom logger implementation showing all available log levels and metrics support
class ExampleCustomLogger: LiveboxLogger, LiveboxMetricsLogger {

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    private func levelEmoji(_ level: LiveboxLogLevel) -> String {
        switch level {
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .default: return "📋"
        case .error: return "❌"
        case .fault: return "💥"
        }
    }

    func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        let timestamp = dateFormatter.string(from: Date())
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "unknown"
        let emoji = levelEmoji(level)

        print("\(emoji) [\(timestamp)] REQUEST: \(method) \(url)")

        // Log headers (excluding sensitive ones)
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            let safeHeaders = headers.filter { !$0.key.lowercased().contains("authorization") }
            if !safeHeaders.isEmpty {
                print("   Headers: \(safeHeaders)")
            }
        }

        // Log body size if present
        if let body = body {
            print("   Body: \(body.count) bytes")
            if body.count < 200, let bodyString = String(data: body, encoding: .utf8) {
                print("   Content: \(bodyString)")
            }
        }
    }

    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        let timestamp = dateFormatter.string(from: Date())
        let emoji = levelEmoji(level)

        if let error = error {
            print("\(emoji) [\(timestamp)] ERROR: \(error.localizedDescription)")
            return
        }

        guard let response = response else {
            print("\(emoji) [\(timestamp)] ERROR: No response received")
            return
        }

        let statusCode = response.statusCode
        let url = response.url?.absoluteString ?? "unknown"
        let duration = String(format: "%.3f", metrics.duration)

        print("\(emoji) [\(timestamp)] RESPONSE: \(statusCode) \(url) (\(duration)s)")

        if let data = data {
            let size = ByteCountFormatter().string(fromByteCount: Int64(data.count))
            print("   Response: \(size)")

            if data.count < 200, let responseString = String(data: data, encoding: .utf8) {
                print("   Content: \(responseString)")
            }
        }
    }

    func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        let timestamp = dateFormatter.string(from: Date())
        let emoji = levelEmoji(level)

        print("\(emoji) [\(timestamp)] METRICS:")
        print("   Duration: \(String(format: "%.3f", metrics.duration))s")
        print("   Status: \(metrics.statusCode?.description ?? "N/A")")
        print("   Request: \(metrics.requestBodySize) bytes")
        print("   Response: \(metrics.responseBodySize) bytes")
        print("   Error: \(metrics.hadError ? "Yes" : "No")")
    }
}

/// Convenience extension for debugging configuration
extension LiveboxConfiguration {

    /// Convenience method to check the current logging status
    static func printCurrentLoggingStatus() {
        let config = LiveboxConfiguration.shared

        print("Current Logging Status:")
        print("  Enabled: \(config.isLoggingEnabled)")
        print("  Minimum Log Level: \(config.minimumLogLevel.rawValue)")
        print("  Metrics Logging: \(config.metricsLoggingEnabled ? "Enabled" : "Disabled")")

        if config.isUsingLogger(ofType: DefaultLiveboxLogger.self) {
            print("  Type: Default OSLog Logger")
        } else if config.isUsingLogger(ofType: SilentLiveboxLogger.self) {
            print("  Type: Silent Logger (Disabled)")
        } else {
            print("  Type: Custom Logger (\(type(of: config.logger)))")
        }
        print()
    }
}
