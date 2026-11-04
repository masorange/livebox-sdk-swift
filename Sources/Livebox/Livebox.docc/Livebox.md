# ``Livebox``

Configure and monitor Livebox and compatible routers through their local REST API.

## Overview

Livebox lets you read router information, manage Wi-Fi interfaces and access points,
list connected devices and configure Wi-Fi and parental control schedules.

Every operation is backed by a router *feature*. The router publishes the features it supports
through its capabilities endpoint, so fetch them (or call ``LiveboxAPI/login(username:password:completion:)``)
before using any other method.

```swift
let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")

api.login(password: "admin-password") { result in
    guard case .success = result else { return }

    api.getGeneralInfo { result in
        switch result {
        case .success(let info):
            print("Router model: \(info.modelName)")
        case .failure(let error):
            print("Failed to get router info: \(error)")
        }
    }
}
```

> Tip: Add the `LiveboxAsync` library to use the same API with `async`/`await`.

### Authentication

The router API has no sessions. Credentials are sent with every request using HTTP Basic Authentication.
Use ``LiveboxAPI/login(username:password:completion:)`` to set and validate credentials, or
``LiveboxAPI/updateCredentials(username:password:)`` to set them without validation.

### Logging

HTTP requests and responses are logged with OSLog by default. Use ``LiveboxConfiguration`` to change this:

```swift
// Disable logging completely
LiveboxConfiguration.disableLogging()

// Only log errors and faults
LiveboxConfiguration.setMinimumLogLevel(.error)

// Stop logging performance metrics
LiveboxConfiguration.setMetricsLogging(enabled: false)
```

To send logs to your own system, implement ``LiveboxLogger`` (and optionally ``LiveboxMetricsLogger``):

```swift
final class MyLogger: LiveboxLogger {
    func logRequest(_ request: URLRequest, body: Data?, level: LiveboxLogLevel) {
        print("[\(level)] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    }

    func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, level: LiveboxLogLevel, metrics: HTTPMetrics) {
        print("[\(level)] \(response?.statusCode ?? 0) in \(String(format: "%.3f", metrics.duration))s")
    }
}

LiveboxConfiguration.setLogger(MyLogger())
```

## Topics

### Essentials

- ``LiveboxAPI``
- ``LiveboxError``
- ``LiveboxInfo``

### Router Information

- ``GeneralInfo``
- ``Capabilities``
- ``FeatureID``

### Wi-Fi

- ``Wifi``
- ``WlanInterface``
- ``AccessPoint``

### Connected Devices

- ``DeviceInfo``
- ``DeviceDetail``

### Schedules

- ``Schedules``
- ``Schedule``
- ``ScheduleID``
- ``Weekday``
- ``DeviceScheduleStatus``
- ``WlanScheduleStatus``

### Logging

- ``LiveboxConfiguration``
- ``LiveboxLogger``
- ``LiveboxMetricsLogger``
- ``DefaultLiveboxLogger``
- ``SilentLiveboxLogger``
- ``LiveboxLogLevel``
- ``HTTPMetrics``

### Custom Clients

- ``LiveboxClient``
- ``LiveboxClientConfiguration``
- ``LiveboxClientFactory``
- ``HTTPMethod``

### Decoding Helpers

- ``FlexibleInt``
