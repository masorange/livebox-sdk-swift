import Foundation

/// The global configuration of the Livebox SDK.
///
/// Use it to configure how HTTP requests and responses are logged.
public final class LiveboxConfiguration {

    /// The shared singleton instance of the configuration.
    public static let shared = LiveboxConfiguration()

    /// The logger used for HTTP requests and responses.
    ///
    /// Defaults to a ``DefaultLiveboxLogger``.
    public var logger: LiveboxLogger {
        didSet {
            updateLoggingStatus()
        }
    }

    /// Whether logging is enabled.
    ///
    /// It's `false` only when the logger is a ``SilentLiveboxLogger``.
    public private(set) var isLoggingEnabled: Bool

    /// The minimum level of the messages to log. Defaults to ``LiveboxLogLevel/debug``.
    ///
    /// Applied by ``DefaultLiveboxLogger``. Custom loggers receive every message and can read this value to filter them.
    public var minimumLogLevel: LiveboxLogLevel = .debug

    /// Whether performance metrics are logged. Defaults to `true`.
    ///
    /// Applied by ``DefaultLiveboxLogger``. Custom loggers can read this value to decide whether to log metrics.
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

    /// Enables logging with a new ``DefaultLiveboxLogger``.
    /// - Parameter subsystem: The OSLog subsystem. Defaults to the main bundle identifier, or `com.masorange.livebox` if there is none.
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

    /// Enables logging with a new ``DefaultLiveboxLogger`` on the shared configuration.
    public static func enableDefaultLogging() {
        shared.enableLogging()
    }

    /// Disables logging on the shared configuration.
    public static func disableLogging() {
        shared.disableLogging()
    }

    /// Sets a custom logger on the shared configuration.
    /// - Parameter logger: The custom logger to use
    public static func setLogger(_ logger: LiveboxLogger) {
        shared.setCustomLogger(logger)
    }

    /// Sets the minimum log level on the shared configuration.
    /// - Parameter level: The minimum level to log
    public static func setMinimumLogLevel(_ level: LiveboxLogLevel) {
        shared.minimumLogLevel = level
    }

    /// Enables or disables metrics logging on the shared configuration.
    /// - Parameter enabled: Whether to enable metrics logging
    public static func setMetricsLogging(enabled: Bool) {
        shared.metricsLoggingEnabled = enabled
    }
}
