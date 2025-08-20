import Foundation
import Livebox

/// LiveboxAsync module provides async/await alternatives to the callback-based methods in Livebox.
///
/// This module extends the functionality of the Livebox module with modern Swift concurrency support,
/// allowing developers to use async/await syntax when interacting with Livebox routers.
///
/// ## Usage Examples
///
/// Using async/await syntax:
///
/// ```swift
/// // Create a service
/// let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")
///
/// // Using async/await
/// do {
///     // Get router capabilities
///     let capabilities = try await service.fetchCapabilities()
///     print("Available features: \(capabilities.features)")
///
///     // Get router info
///     let info = try await service.getGeneralInfo()
///     print("Router model: \(info.modelName)")
/// } catch {
///     print("Error: \(error)")
/// }
/// ```
///
/// You can also use the `AsyncLiveboxAPI` typealias for better code readability:
///
/// ```swift
/// let asyncAPI: AsyncLiveboxAPI = try LiveboxAPI(baseURLString: "http://192.168.1.1")
///
/// Task {
///     do {
///         let wifiInterfaces = try await asyncAPI.getWifiInterfaces()
///         print("Found \(wifiInterfaces.count) WiFi interfaces")
///     } catch {
///         print("Failed to get WiFi interfaces: \(error)")
///     }
/// }
/// ```
///
/// This module is designed to work alongside the main Livebox module, giving developers
/// the flexibility to choose between callback-based and async/await patterns based on their needs.
public struct LiveboxAsync {
    /// The current version of the LiveboxAsync package.
    public static let version = Livebox.version

    private init() {}
}
