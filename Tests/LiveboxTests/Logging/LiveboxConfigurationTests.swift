import Foundation
import Testing

@testable import Livebox

@Suite("Livebox Configuration Tests")
struct LiveboxConfigurationTests {

    @Test("Default configuration has logging enabled")
    func defaultConfigurationIsLoggingEnabled() {
        // Create a fresh configuration for testing
        let defaultLogger = DefaultLiveboxLogger()

        // Test that default logger is not silent
        #expect(!(defaultLogger is SilentLiveboxLogger), "Default logger should not be silent")

        // Test that logging would be enabled with default logger
        let isDefaultLoggingEnabled = !(defaultLogger is SilentLiveboxLogger)
        #expect(isDefaultLoggingEnabled, "Logging should be enabled by default")
    }

    @Test("Silent logger can be created")
    func silentLoggerCreation() {
        let silentLogger = SilentLiveboxLogger()

        // Test that we can create a silent logger
        #expect(silentLogger is SilentLiveboxLogger, "Should be able to create SilentLiveboxLogger")

        // Test that silent logger implements the protocol
        #expect(silentLogger is LiveboxLogger, "SilentLiveboxLogger should implement LiveboxLogger")
    }

    @Test("Configuration static methods work")
    func staticMethods() {
        // Test that static methods don't crash
        LiveboxConfiguration.enableDefaultLogging()
        LiveboxConfiguration.disableLogging()
        LiveboxConfiguration.setMinimumLogLevel(.error)
        LiveboxConfiguration.setMetricsLogging(enabled: false)
        LiveboxConfiguration.setMetricsLogging(enabled: true)

        // These should complete without errors
        #expect(Bool(true), "Static methods should not crash")
    }

    @Test("Custom logger can be set")
    func customLogger() {
        let testLogger = TestLogger()

        // Test that custom logger implements the required protocols
        #expect(testLogger is LiveboxLogger, "TestLogger should implement LiveboxLogger")
        #expect(testLogger is LiveboxMetricsLogger, "TestLogger should implement LiveboxMetricsLogger")

        // Test that we can call the logger methods without crashing
        let request = URLRequest(url: URL(string: "http://example.com")!)
        testLogger.logRequest(request, body: nil, level: .info)

        let metrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent(),
            responseTime: CFAbsoluteTimeGetCurrent(),
            statusCode: 200,
            requestBodySize: 0,
            responseBodySize: 0,
            hadError: false
        )
        testLogger.logResponse(nil, data: nil, error: nil, level: .info, metrics: metrics)
        testLogger.logMetrics(metrics, level: .debug)

        #expect(testLogger.requestLogs.count == 1, "Should have logged one request")
        #expect(testLogger.responseLogs.count == 1, "Should have logged one response")
        #expect(testLogger.metricsLogs.count == 1, "Should have logged one metrics entry")
    }
}

@Suite("Log Level Tests")
struct LiveboxLogLevelTests {

    @Test("Log level priorities are correct")
    func logLevelPriorities() {
        #expect(LiveboxLogLevel.debug.priority < LiveboxLogLevel.info.priority)
        #expect(LiveboxLogLevel.info.priority < LiveboxLogLevel.default.priority)
        #expect(LiveboxLogLevel.default.priority < LiveboxLogLevel.error.priority)
        #expect(LiveboxLogLevel.error.priority < LiveboxLogLevel.fault.priority)
    }

    @Test("OSLogType conversion works")
    func osLogTypeConversion() {
        #expect(LiveboxLogLevel.debug.osLogType == .debug)
        #expect(LiveboxLogLevel.info.osLogType == .info)
        #expect(LiveboxLogLevel.default.osLogType == .default)
        #expect(LiveboxLogLevel.error.osLogType == .error)
        #expect(LiveboxLogLevel.fault.osLogType == .fault)
    }

    @Test("All log levels can be created")
    func allLogLevelsExist() {
        let allLevels: [LiveboxLogLevel] = [.debug, .info, .default, .error, .fault]
        #expect(allLevels.count == 5, "Should have 5 log levels")

        // Test that each level has a unique priority
        let priorities = allLevels.map { $0.priority }
        let uniquePriorities = Set(priorities)
        #expect(priorities.count == uniquePriorities.count, "All log levels should have unique priorities")
    }
}

@Suite("HTTP Metrics Tests")
struct HTTPMetricsTests {

    @Test("Metrics duration calculation")
    func metricsCalculation() {
        let startTime = CFAbsoluteTimeGetCurrent()
        let endTime = startTime + 0.5  // 500ms later

        let metrics = HTTPMetrics(
            requestStartTime: startTime,
            responseTime: endTime,
            statusCode: 200,
            requestBodySize: 100,
            responseBodySize: 500,
            hadError: false
        )

        #expect(abs(metrics.duration - 0.5) < 0.001, "Duration should be approximately 0.5 seconds")
        #expect(metrics.statusCode == 200)
        #expect(metrics.requestBodySize == 100)
        #expect(metrics.responseBodySize == 500)
        #expect(!metrics.hadError)
    }

    @Test("Error metrics")
    func errorMetrics() {
        let metrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent(),
            responseTime: CFAbsoluteTimeGetCurrent(),
            statusCode: nil,
            requestBodySize: 0,
            responseBodySize: 0,
            hadError: true
        )

        #expect(metrics.statusCode == nil)
        #expect(metrics.hadError)
        #expect(metrics.duration >= 0, "Duration should not be negative")
    }

    @Test("Large metrics values")
    func largeMetricsValues() {
        let metrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent() - 10,
            responseTime: CFAbsoluteTimeGetCurrent(),
            statusCode: 500,
            requestBodySize: 1_000_000,  // 1MB
            responseBodySize: 5_000_000,  // 5MB
            hadError: true
        )

        #expect(metrics.duration > 5, "Duration should be significant")
        #expect(metrics.requestBodySize == 1_000_000)
        #expect(metrics.responseBodySize == 5_000_000)
    }
}

@Suite("Default Logger Tests")
struct DefaultLiveboxLoggerTests {

    @Test("Default logger can be created")
    func defaultLoggerCreation() {
        let logger = DefaultLiveboxLogger(subsystem: "com.test.logging")

        #expect(logger is LiveboxLogger, "Should implement LiveboxLogger")
        #expect(logger is LiveboxMetricsLogger, "Should implement LiveboxMetricsLogger")
    }

    @Test("Logging methods don't crash")
    func loggingMethodsDontCrash() {
        let logger = DefaultLiveboxLogger(subsystem: "com.test.logging")

        let url = URL(string: "http://example.com/api/test")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer token123", forHTTPHeaderField: "Authorization")

        let body = "test data".data(using: .utf8)

        // These should not crash
        logger.logRequest(request, body: body, level: .info)
        logger.logRequest(request, body: nil, level: .debug)

        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )
        let responseData = "response data".data(using: .utf8)
        let metrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent(),
            responseTime: CFAbsoluteTimeGetCurrent() + 0.1,
            statusCode: 200,
            requestBodySize: body?.count ?? 0,
            responseBodySize: responseData?.count ?? 0,
            hadError: false
        )

        logger.logResponse(response, data: responseData, error: nil, level: .info, metrics: metrics)

        let error = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let errorMetrics = HTTPMetrics(
            requestStartTime: CFAbsoluteTimeGetCurrent(),
            responseTime: CFAbsoluteTimeGetCurrent(),
            statusCode: nil,
            requestBodySize: 0,
            responseBodySize: 0,
            hadError: true
        )
        logger.logResponse(nil, data: nil, error: error, level: .error, metrics: errorMetrics)

        logger.logMetrics(metrics, level: .debug)

        // If we get here, nothing crashed
        #expect(true, "All logging methods should complete without crashing")
    }

    @Test("All log levels work")
    func allLogLevelsWork() {
        let logger = DefaultLiveboxLogger(subsystem: "com.test.logging")
        let request = URLRequest(url: URL(string: "http://example.com")!)

        // Test all log levels
        logger.logRequest(request, body: nil, level: .debug)
        logger.logRequest(request, body: nil, level: .info)
        logger.logRequest(request, body: nil, level: .default)
        logger.logRequest(request, body: nil, level: .error)
        logger.logRequest(request, body: nil, level: .fault)

        #expect(true, "All log levels should work without crashing")
    }
}

@Suite("Logger Protocol Default Implementations")
struct LoggerProtocolTests {

    @Test("Default implementations work")
    func defaultImplementations() {
        let testLogger = TestLogger()

        // Test backward compatibility methods
        testLogger.logRequest(URLRequest(url: URL(string: "http://example.com")!), body: nil)
        testLogger.logResponse(nil, data: nil, error: nil)

        #expect(testLogger.requestLogs.count == 1, "Should have logged one request")
        #expect(testLogger.responseLogs.count == 1, "Should have logged one response")
    }
}

// MARK: - Test Logger Implementation

final class TestLogger: LiveboxLogger, LiveboxMetricsLogger {
    private(set) var requestLogs: [(URLRequest, Data?, LiveboxLogLevel)] = []
    private(set) var responseLogs: [(HTTPURLResponse?, Data?, Error?, LiveboxLogLevel, HTTPMetrics)] = []
    private(set) var metricsLogs: [(HTTPMetrics, LiveboxLogLevel)] = []

    func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        requestLogs.append((request, body, level))
    }

    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        responseLogs.append((response, data, error, level, metrics))
    }

    func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        metricsLogs.append((metrics, level))
    }

    func reset() {
        requestLogs.removeAll()
        responseLogs.removeAll()
        metricsLogs.removeAll()
    }
}
