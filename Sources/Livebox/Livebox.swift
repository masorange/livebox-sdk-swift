import Foundation

/// The Livebox module provides APIs to interact with Livebox and other compatible routers.
///
/// This module allows for easy configuration and monitoring of network devices,
/// retrieving system information, managing Wi-Fi settings, and more.
///
/// To get started, create a LiveboxAPI instance with the router's base URL, then
/// use the service's methods to interact with the router.
///
/// ```swift
/// // Create a service
/// let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")
/// // Get router capabilities
/// service.getCapabilities { result in
///    switch result {
///   case .success(let capabilities):
///        print("Available features: \(capabilities.features)")
///    case .failure(let error):
///       print("Failed to get capabilities: \(error)")
///   }
/// }
///
/// // Get router info
/// service.getGeneralInfo { result in
///     switch result {
///     case .success(let info):
///         print("Router model: \(info.modelName)")
///     case .failure(let error):
///         print("Failed to get router info: \(error)")
///     }
/// }
/// ```
///
/// ## Logging Configuration
///
/// Livebox provides configurable logging for HTTP requests and responses with support for log levels and performance metrics. By default, logging is enabled using OSLog.
///
/// ```swift
/// // Default logging is already enabled, but you can configure it:
/// LiveboxConfiguration.enableDefaultLogging()
///
/// // Disable logging completely:
/// LiveboxConfiguration.disableLogging()
///
/// // Set minimum log level (debug, info, default, error, fault):
/// LiveboxConfiguration.setMinimumLogLevel(.error)
///
/// // Enable/disable performance metrics logging:
/// LiveboxConfiguration.setMetricsLogging(enabled: false)
///
/// // Use a custom logger with log levels and metrics:
/// class MyCustomLogger: LiveboxLogger, LiveboxMetricsLogger {
///     func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
///         print("🚀 [\(level)] Making request to: \(request.url?.absoluteString ?? "unknown")")
///     }
///
///     func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
///         if let error = error {
///             print("❌ [\(level)] Request failed: \(error)")
///         } else if let response = response {
///             print("✅ [\(level)] Response: \(response.statusCode) (took \(String(format: "%.3f", metrics.duration))s)")
///         }
///     }
///
///     func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
///         print("📊 [\(level)] Metrics: \(metrics.duration)s, \(metrics.responseBodySize) bytes")
///     }
/// }
///
/// LiveboxConfiguration.setLogger(MyCustomLogger())
/// ```
///
/// ## Available Models
///
/// - `GeneralInfo`: Information about the router device
/// - `Capabilities`: Router API capabilities and features
public struct LiveboxInfo {
    /// The current version of the Livebox package.
    public static let version = "1.5.0"
}
