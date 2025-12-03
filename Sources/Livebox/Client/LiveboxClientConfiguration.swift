import Foundation

/// Configuration options for the LiveboxClient.
public struct LiveboxClientConfiguration {
    /// The base URL for the router API (e.g., "http://192.168.1.1" or "http://livebox.home").
    let baseURL: URL

    /// Default timeout for network requests in seconds.
    let timeout: TimeInterval

    /// Default headers to include with every request.
    let defaultHeaders: [String: String]

    /// Username for HTTP Basic Authentication.
    let username: String?

    /// Password for HTTP Basic Authentication.
    let password: String?

    /// Creates a new configuration with the specified parameters.
    /// - Parameters:
    ///   - baseURL: The base URL for the router API.
    ///   - timeout: The timeout for network requests in seconds. Default is 60 seconds.
    ///   - defaultHeaders: Default headers to include with every request. Defaults to empty dictionary.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    public init(
        baseURL: URL,
        timeout: TimeInterval = 60.0,
        defaultHeaders: [String: String] = [:],
        username: String? = nil,
        password: String? = nil
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.defaultHeaders = defaultHeaders
        self.username = username
        self.password = password
    }

    /// Creates a new configuration with a string URL.
    /// - Parameters:
    ///   - baseURLString: The base URL string for the router API. Should be a valid URL.
    ///   - timeout: The timeout for network requests in seconds. Default is 60 seconds.
    ///   - defaultHeaders: Default headers to include with every request. Defaults to empty dictionary.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    /// - Throws: An error if the baseURLString is not a valid URL.
    public init(
        baseURLString: String,
        timeout: TimeInterval = 60.0,
        defaultHeaders: [String: String] = [:],
        username: String? = nil,
        password: String? = nil
    ) throws(LiveboxError) {
        guard let url = URL(string: baseURLString) else {
            throw LiveboxError.invalidURL(baseURLString)
        }
        self.baseURL = url
        self.timeout = timeout
        self.defaultHeaders = defaultHeaders
        self.username = username
        self.password = password
    }
}
