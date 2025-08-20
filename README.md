# Livebox iOS SDK

A Swift package for interacting with Livebox routers. This SDK provides a clean, type-safe way to interact with router APIs without hardcoding endpoints.

## Features

- 🔄 **Dynamic API Discovery**: Automatically fetches and works with the capabilities of your router
- 🔒 **Type Safety**: Swift's type system ensures your API calls are correct
- ⚙️ **Flexible Configuration**: Support for different router models with varying capabilities
- 🔀 **Multiple Programming Styles**: Choose between traditional callbacks or modern async/await

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/masorange/apps-livebox-sdk-swift.git", .upToNextMajor(from: "1.0.0"))
]
```

Or add it directly in Xcode:
1. Go to File > Swift Packages > Add Package Dependency
2. Enter the repository URL: `https://github.com/masorange/apps-livebox-sdk-swift.git`

## Quick Start

The SDK now provides a flexible authentication model that makes dependency injection easy:

```swift
import Livebox

// Recommended: Create service without authentication first
let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")

// Authenticate when needed
try await service.login(password: "yourpassword")

// Alternative: Create service with authentication upfront (legacy style)
let authenticatedService = try LiveboxAPI(
    baseURLString: "http://192.168.1.1",
    username: "admin",
    password: "yourpassword"
)
```

The project uses Swift's new Testing framework for unit tests instead of XCTest, providing a more modern and declarative testing experience.

## Usage

The SDK offers two programming styles: traditional completion handlers (callbacks) and modern async/await. Choose whichever style best fits your development needs.

### Callback Style

```swift
import Livebox

// Create a service for your router
let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")

// Authenticate with the router
service.login(username: "admin", password: "yourpassword") { result in
    switch result {
    case .success(let capabilities):
        print("Successfully authenticated. Available features: \(capabilities.features.count)")

        // Now you can make authenticated requests
        service.getGeneralInfo { result in
            switch result {
            case .success(let info):
                print("Router model: \(info.modelName)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    case .failure(let error):
        print("Authentication failed: \(error)")
    }
}
```

### Async/Await Style

```swift
import Livebox
import LiveboxAsync

// Create a service for your router
let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")

// Use async/await for more readable asynchronous code
Task {
    do {
        // Authenticate first
        let capabilities = try await service.login(username: "admin", password: "yourpassword")
        print("Successfully authenticated. Features: \(capabilities.features.count)")

        // Now make authenticated requests
        let info = try await service.getGeneralInfo()
        print("Router model: \(info.modelName)")
    } catch {
        print("Error: \(error)")
    }
}

// You can also use the AsyncLiveboxAPI typealias for better readability
let asyncService: AsyncLiveboxAPI = try LiveboxAPI(baseURLString: "http://192.168.1.1")
```

### Authentication

The SDK provides a modern, flexible authentication model that solves common architectural problems:

**Key Benefits:**
- ✅ **Dependency Injection Friendly**: Create services without credentials upfront
- ✅ **Runtime Authentication**: Change credentials at any time
- ✅ **State Management**: Track authentication status
- ✅ **Error Recovery**: Failed login attempts don't break existing sessions

#### Login Method (Recommended)

```swift
// Create service without credentials
let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")

// Authenticate when needed (also fetches capabilities)
service.login(username: "admin", password: "yourpassword") { result in
    switch result {
    case .success(let capabilities):
        print("Authenticated! Router has \(capabilities.features.count) features")
        // Service is now authenticated and ready to use
    case .failure(let error):
        print("Authentication failed: \(error)")
    }
}
```

#### Async Login

```swift
do {
    let capabilities = try await service.login(username: "admin", password: "yourpassword")
    print("Authenticated! Router has \(capabilities.features.count) features")
} catch {
    print("Authentication failed: \(error)")
}
```

#### Managing Authentication State

```swift
// Check authentication status
if service.authenticated {
    print("Currently authenticated as: \(service.currentUsername ?? "unknown")")
}

// Change credentials without validation
try service.updateCredentials(username: "newuser", password: "newpass")

// Or login with new credentials (validates them)
try await service.login(username: "newuser", password: "newpass")

// Logout (clears credentials)
service.logout()
```

### Fetching Router Capabilities

The `login` method automatically fetches capabilities, but you can also fetch them separately:

```swift
service.fetchCapabilities { result in
    switch result {
    case .success(let capabilities):
        for feature in capabilities.features {
            print("\(feature.id): \(feature.uri) - Operations: \(feature.ops)")
        }
    case .failure(let error):
        print("Failed to fetch capabilities: \(error)")
    }
}
```

### Getting Connected Devices

#### Using Callbacks

```swift
service.getConnectedDevices { result in
    switch result {
    case .success(let devices):
        for device in devices {
            print("Device: \(device.alias)")
        }
    case .failure(let error):
        print("Failed to get connected devices: \(error)")
    }
}
```

### Working with Wi-Fi Settings

#### Using Callbacks

```swift
// Get Wi-Fi configuration
service.getWifiConfig { result in
    switch result {
    case .success(let wifiConfig):
        print("Wi-Fi config: \(wifiConfig.keys)")
    case .failure(let error):
        print("Failed to get Wi-Fi config: \(error)")
    }
}

// Get specific WLAN interface
service.getWlanInterface(wlanIfc: "2.4GHz") { result in
    switch result {
    case .success(let wlanConfig):
        print("WLAN 2.4GHz: \(wlanConfig.keys)")
    case .failure(let error):
        print("Failed to get WLAN interface: \(error)")
    }
}
```

#### Using Async/Await

```swift
// Get Wi-Fi interfaces
do {
    let interfaces = try await service.getWifiInterfaces()
    print("Found \(interfaces.count) WiFi interfaces")

    // Get specific interface details
    if !interfaces.isEmpty {
        let wlanInterface = try await service.getWifiInterface(id: interfaces[0].id)
        print("Interface: \(wlanInterface.SSID) on channel \(wlanInterface.channel)")
    }
} catch {
    print("Error working with WiFi: \(error)")
}
```

## Which Style Should I Choose?

- **Callbacks**: Best for projects that need to support older iOS versions (below iOS 13)
- **Async/Await**: Best for modern projects with iOS 13+ support, provides cleaner code and better error handling

You can import just the modules you need:
- `import Livebox` - For callback-based APIs
- `import LiveboxAsync` - To enable async/await support

## Minimum Requirements

- iOS 13.0+ / macOS 10.15+ (for async/await support)
- Swift 5.5+
- Swift Testing framework for unit tests
- For callback-only usage, there are no minimum OS version requirements
