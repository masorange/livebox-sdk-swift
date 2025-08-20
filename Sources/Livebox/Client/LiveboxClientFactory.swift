import Foundation

/// Factory class to create LiveboxClient instances.
/// This makes it easier to switch between real and mock implementations.
public final class LiveboxClientFactory {

    /// Creates a real LiveboxClient implementation that connects to a real router.
    /// - Parameters:
    ///   - baseURLString: The base URL string for the router API.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    /// - Returns: A LiveboxClient implementation that connects to a real router.
    /// - Throws: An error if the baseURLString is not a valid URL.
    public static func createClient(
        baseURLString: String,
        username: String? = nil,
        password: String? = nil
    ) throws -> LiveboxClient {
        return try DefaultLiveboxClient(
            baseURLString: baseURLString,
            username: username,
            password: password
        )
    }

    /// Creates a real LiveboxClient implementation that connects to a real router.
    /// - Parameters:
    ///   - baseURL: The base URL for the router API.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    /// - Returns: A LiveboxClient implementation that connects to a real router.
    public static func createClient(
        baseURL: URL,
        username: String? = nil,
        password: String? = nil
    ) -> LiveboxClient {
        return DefaultLiveboxClient(
            baseURL: baseURL,
            username: username,
            password: password
        )
    }

    /// Creates a mock LiveboxClient implementation for testing purposes.
    /// - Returns: A LiveboxClient mock implementation.
    static func createMockClient() -> MockLiveboxClient {
        return MockLiveboxClient()
    }
}
