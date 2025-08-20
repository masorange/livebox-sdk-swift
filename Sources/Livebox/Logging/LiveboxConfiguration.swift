import Foundation

/// Global configuration for the Livebox framework.
/// This class provides a centralized way to configure logging and other framework-wide settings.
public final class LiveboxConfiguration {

    /// The shared singleton instance of the configuration.
    public static let shared = LiveboxConfiguration()

    /// The logger instance to use for HTTP requests and responses.
    /// By default, uses `DefaultLiveboxLogger` with logging enabled.
    public var logger: LiveboxLogger {
        didSet {
            updateLoggingStatus()
        }
    }

    /// Whether logging is currently enabled.
    /// This is automatically updated when the logger is changed.
    public private(set) var isLoggingEnabled: Bool

    /// The minimum log level for messages to be logged.
    /// Messages below this level will be filtered out.
    public var minimumLogLevel: LiveboxLogLevel = .debug

    /// Whether metrics logging is enabled.
    /// When true, performance metrics will be logged separately.
    public var metricsLoggingEnabled: Bool = true

    /// Private initializer to enforce singleton pattern.
    private init() {
        self.isLoggingEnabled = true
        self.logger = DefaultLiveboxLogger()
    }

    /// Updates the logging status based on the current logger type.
    private func updateLoggingStatus() {
        isLoggingEnabled = !(logger is SilentLiveboxLogger)
    }

    /// Enables logging using the default OSLog-based logger.
    /// - Parameter subsystem: The subsystem identifier for logging. Defaults to the bundle identifier.
    public func enableLogging(subsystem: String = Bundle.main.bundleIdentifier ?? "com.masorange.livebox") {
        self.logger = DefaultLiveboxLogger(subsystem: subsystem)
    }

    /// Disables all logging by setting a silent logger.
    public func disableLogging() {
        self.logger = SilentLiveboxLogger()
    }

    /// Sets a custom logger implementation.
    /// - Parameter customLogger: The custom logger to use
    public func setCustomLogger(_ customLogger: LiveboxLogger) {
        self.logger = customLogger
    }

    /// Convenience method to check if a specific logger type is currently being used.
    /// - Parameter loggerType: The type of logger to check for
    /// - Returns: True if the current logger is of the specified type
    public func isUsingLogger<T: LiveboxLogger>(ofType loggerType: T.Type) -> Bool {
        return logger is T
    }

    /// Resets the configuration to default state for testing purposes.
    /// This method is intended for testing and should not be used in production code.
    internal func resetToDefault() {
        self.minimumLogLevel = .debug
        self.metricsLoggingEnabled = true
        self.logger = DefaultLiveboxLogger()
        self.isLoggingEnabled = true
    }
}

// MARK: - Convenience Extensions

extension LiveboxConfiguration {

    /// Quick access to enable default logging.
    public static func enableDefaultLogging() {
        shared.enableLogging()
    }

    /// Quick access to disable logging.
    public static func disableLogging() {
        shared.disableLogging()
    }

    /// Quick access to set a custom logger.
    /// - Parameter logger: The custom logger to use
    public static func setLogger(_ logger: LiveboxLogger) {
        shared.setCustomLogger(logger)
    }

    /// Sets the minimum log level for filtering.
    /// - Parameter level: The minimum level to log
    public static func setMinimumLogLevel(_ level: LiveboxLogLevel) {
        shared.minimumLogLevel = level
    }

    /// Enables or disables metrics logging.
    /// - Parameter enabled: Whether to enable metrics logging
    public static func setMetricsLogging(enabled: Bool) {
        shared.metricsLoggingEnabled = enabled
    }
}
