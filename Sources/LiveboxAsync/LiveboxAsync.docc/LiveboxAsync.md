# ``LiveboxAsync``

Use the Livebox API with Swift concurrency.

## Overview

LiveboxAsync extends ``Livebox/LiveboxAPI`` with `async` versions of its callback-based methods.
Every method throws `LiveboxError`, so you can catch it without casting.

```swift
import Livebox
import LiveboxAsync

let api = try LiveboxAPI(baseURLString: "http://192.168.1.1")

do {
    _ = try await api.login(password: "admin-password")

    let info = try await api.getGeneralInfo()
    print("Router model: \(info.modelName)")

    let interfaces = try await api.getWifiInterfaces().wifiInterfaces
    print("Found \(interfaces.count) Wi-Fi interfaces")
} catch {
    print("Error: \(error.localizedDescription)")
}
```

The async methods wrap the callback-based ones, so both styles can be mixed on the same ``Livebox/LiveboxAPI`` instance.

## Topics

### Essentials

- ``AsyncLiveboxAPI``
- ``LiveboxAsync``
