# Livebox Logging System Implementation Summary

This document provides a technical overview of the enhanced configurable logging system implemented for the Livebox framework.

## Overview

The logging system provides configurable HTTP request/response logging with log levels and performance metrics for the `DefaultLiveboxClient` without requiring developers to have direct access to the client implementation. The system is designed to be:

- **Developer-friendly**: Simple configuration through global settings
- **Flexible**: Support for custom logging implementations with log levels
- **Performance-aware**: Built-in metrics collection and reporting
- **Privacy-conscious**: Automatic masking of sensitive information
- **Level-based filtering**: Support for debug, info, default, error, and fault levels
- **Metrics-enabled**: Response time measurement and request statistics
- **Cross-platform**: Compatible with iOS 13+ and macOS 10.15+
- **Testing framework ready**: Uses Swift Testing instead of XCTest

## Architecture

### Core Components

1. **LiveboxLogger Protocol** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - Defines the interface for custom logging implementations
   - Enhanced methods: `logRequest(_:body:level:)` and `logResponse(_:data:error:level:metrics:)`
   - Backward compatibility through default implementations
   - Support for log levels matching OSLogType (debug, info, default, error, fault)

2. **LiveboxMetricsLogger Protocol** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - Extended protocol for loggers that want to handle metrics separately
   - Method: `logMetrics(_:level:)` for detailed performance data

3. **HTTPMetrics Struct** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - Captures request timing, response sizes, and error states
   - Automatic duration calculation from start/end timestamps
   - Includes status codes, body sizes, and error flags

4. **LiveboxLogLevel Enum** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - Five levels matching OSLogType: debug, info, default, error, fault
   - Priority-based filtering support
   - Automatic conversion to OSLogType for compatibility

5. **DefaultLiveboxLogger** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - Enhanced OSLog-based implementation with log level support
   - Built-in metrics logging to separate OSLog category
   - Intelligent log level filtering based on global configuration
   - Handles iOS 13+/macOS 10.15+ compatibility with availability checks
   - Automatic privacy protection (masks authorization headers)
   - Size-limited logging for large payloads

6. **SilentLiveboxLogger** (`Sources/Livebox/Logging/LiveboxLogger.swift`)
   - No-op implementation for disabling logging
   - Supports both LiveboxLogger and LiveboxMetricsLogger protocols
   - Used when `LiveboxConfiguration.disableLogging()` is called

7. **LiveboxConfiguration** (`Sources/Livebox/Logging/LiveboxConfiguration.swift`)
   - Enhanced singleton configuration class
   - Global access point for logging settings with level filtering
   - Minimum log level configuration
   - Metrics logging enable/disable toggle
   - Automatic `isLoggingEnabled` state management

### Integration Points

The logging system integrates into the existing framework at a single point:

**DefaultLiveboxClient.request() method** (`Sources/Livebox/Client/DefaultLiveboxClient.swift:114-140`)
```swift
// Log the request if logging is enabled
let requestStartTime = CFAbsoluteTimeGetCurrent()
if LiveboxConfiguration.shared.isLoggingEnabled {
    LiveboxConfiguration.shared.logger.logRequest(request, body: request.httpBody, level: .info)
}

let task = session.dataTask(with: request) { data, response, error in
    let responseTime = CFAbsoluteTimeGetCurrent()

    // Log the response if logging is enabled
    if LiveboxConfiguration.shared.isLoggingEnabled {
        let metrics = HTTPMetrics(
            requestStartTime: requestStartTime,
            responseTime: responseTime,
            statusCode: (response as? HTTPURLResponse)?.statusCode,
            requestBodySize: request.httpBody?.count ?? 0,
            responseBodySize: data?.count ?? 0,
            hadError: error != nil
        )

        let logLevel: LiveboxLogLevel = // Intelligent level assignment based on status
        LiveboxConfiguration.shared.logger.logResponse(
            response as? HTTPURLResponse,
            data: data,
            error: error,
            level: logLevel,
            metrics: metrics
        )
    }
    // ... rest of response handling
}
```

This single integration point ensures all HTTP requests made by any method in `DefaultLiveboxClient` are logged, since all other request methods delegate to the main `request()` method.

## Developer Experience

### Default Behavior
```swift
// Logging is enabled by default with all log levels and metrics
let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")
// All requests are automatically logged via OSLog with performance metrics
```

### Configuration Options
```swift
// Disable logging completely
LiveboxConfiguration.disableLogging()

// Set minimum log level (filters out lower priority logs)
LiveboxConfiguration.setMinimumLogLevel(.error)

// Disable metrics logging for better performance
LiveboxConfiguration.setMetricsLogging(enabled: false)

// Re-enable with custom subsystem
LiveboxConfiguration.shared.enableLogging(subsystem: "com.myapp.networking")

// Use custom logger with log levels and metrics
LiveboxConfiguration.setLogger(MyCustomLogger())
```

### Custom Logger Implementation
```swift
class MyLogger: LiveboxLogger, LiveboxMetricsLogger {
    func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        // Custom request logging logic with level support
    }

    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        // Custom response logging logic with metrics
    }

    func logMetrics(_ metrics: HTTPMetrics, level: LiveboxLogLevel) {
        // Optional: Handle metrics separately
    }
}
```

## Technical Implementation Details

### Cross-Platform Compatibility

The `DefaultLiveboxLogger` handles different iOS/macOS versions with full log level support:

```swift
if #available(iOS 14.0, macOS 11.0, *) {
    let logger = os.Logger(log)
    switch level {
    case .debug: logger.debug("\(message)")
    case .info: logger.info("\(message)")
    case .default: logger.log("\(message)")
    case .error: logger.error("\(message)")
    case .fault: logger.fault("\(message)")
    }
} else {
    os_log("%{public}@", log: log, type: level.osLogType, message)
}
```

This ensures the framework works on iOS 13+ and macOS 10.15+ with full log level support as specified in `Package.swift`.

### Privacy Protection

The `DefaultLiveboxLogger` automatically sanitizes sensitive information:

```swift
private func sanitizeHeaders(_ headers: [String: String]) -> [String: String] {
    return headers.mapValues { value in
        if headers.keys.contains(where: { $0.lowercased() == "authorization" }) {
            return "***MASKED***"
        }
        return value
    }
}
```

### Performance Optimizations

1. **Conditional Processing**: Logging code only executes when `isLoggingEnabled` is true
2. **Log Level Filtering**: Built-in filtering prevents unnecessary processing of low-priority logs
3. **Metrics Toggle**: Metrics collection can be disabled for minimal performance impact
4. **Size Limits**: Large payloads (>1024 bytes) are truncated in logs
5. **Lazy Evaluation**: Log messages are only formatted when actually needed
6. **Efficient Timing**: CFAbsoluteTime used for high-precision duration measurement

## File Structure

```
Sources/Livebox/Logging/
├── LiveboxLogger.swift          # Protocol + built-in implementations
├── LiveboxConfiguration.swift   # Global configuration singleton
└── README.md                   # Comprehensive usage documentation

Tests/LiveboxTests/Logging/
└── LiveboxConfigurationTests.swift # Unit tests for logging system

Examples/
└── LoggingExample.swift        # Usage examples and demonstrations
```

## Testing Strategy

The implementation includes comprehensive tests using Swift Testing framework:

1. **Unit Tests**: Configuration state management, log level priorities, metrics calculations
2. **Protocol Tests**: Logger interface compliance and backward compatibility
3. **Implementation Tests**: DefaultLiveboxLogger functionality with all log levels
4. **Cross-Platform Tests**: OSLogType conversion and availability handling
5. **Performance Tests**: Metrics timing accuracy and large data handling

## Design Decisions

### Why Global Configuration?

1. **Developer Access**: Developers don't have direct access to `DefaultLiveboxClient`
2. **Simplicity**: Single configuration point for all logging
3. **Framework Integration**: Easy to integrate into existing `LiveboxAPI` usage patterns

### Why Protocol-Based?

1. **Flexibility**: Allows custom logging implementations
2. **Testability**: Easy to mock for testing
3. **Separation of Concerns**: Logging logic is separate from HTTP client logic

### Why Singleton?

1. **Global State**: Logging configuration is inherently global
2. **Thread Safety**: Single point of configuration reduces race conditions
3. **Performance**: Avoids repeated configuration lookups

## Backwards Compatibility

The implementation maintains full backwards compatibility:

- No changes to existing public APIs
- No changes to `LiveboxAPI` interface
- No changes to `LiveboxClientFactory` interface
- Default behavior (logging enabled) matches expected developer experience

## Future Enhancements

Potential future improvements that could be added without breaking changes:

1. **Request Filtering**: Allow selective logging based on endpoints or HTTP methods
2. **Log Sampling**: Percentage-based logging for high-volume applications
3. **Structured Logging**: JSON-formatted logs for better parsing
4. **Async Logging**: Background queue processing for heavy custom loggers
5. **Log Aggregation**: Built-in support for remote logging services
6. **Performance Baselines**: Automatic performance regression detection

## Security Considerations

1. **Credential Protection**: Authorization headers are automatically masked
2. **Data Sensitivity**: Large payloads are truncated to prevent log bloat
3. **Production Safety**: Easy to disable logging for production builds
4. **OSLog Integration**: Respects system-level privacy settings

This enhanced implementation provides a robust, flexible, and developer-friendly logging system with comprehensive log level support and performance metrics that integrates seamlessly with the existing Livebox framework architecture while maintaining full backward compatibility.
