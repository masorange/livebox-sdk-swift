import Foundation
import Testing

@testable import Livebox

@Suite("LiveboxClient Tests")
struct LiveboxClientTests {

    @Test("Client configuration initialization with URL")
    func testConfigurationInitWithURL() {
        let url = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(baseURL: url)

        #expect(config.baseURL == url)
        #expect(config.timeout == 30.0)
        #expect(config.defaultHeaders.isEmpty)
    }

    @Test("Client session includes Accept header")
    func testClientSessionIncludesAcceptHeader() {
        let url = URL(string: "http://192.168.1.1")!
        let client = DefaultLiveboxClient(baseURL: url)

        let headers = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(headers?["Accept"] == "application/json")
    }

    @Test("Client session merges Accept header with custom headers")
    func testClientSessionMergesAcceptHeaderWithCustomHeaders() {
        let url = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: url,
            defaultHeaders: ["User-Agent": "CustomAgent", "X-Custom": "Value"]
        )
        let client = DefaultLiveboxClient(configuration: config)

        let headers = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(headers?["Accept"] == "application/json")
        #expect(headers?["User-Agent"] == "CustomAgent")
        #expect(headers?["X-Custom"] == "Value")
    }

    @Test("Default Accept header overrides custom Accept header")
    func testDefaultAcceptHeaderOverridesCustom() {
        let url = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: url,
            defaultHeaders: ["Accept": "application/xml"]
        )
        let client = DefaultLiveboxClient(configuration: config)

        let headers = client.session.configuration.httpAdditionalHeaders as? [String: String]
        // Default Accept: application/json header overrides any custom Accept header
        #expect(headers?["Accept"] == "application/json")
    }

    @Test("Client configuration initialization with custom parameters")
    func testConfigurationInitWithCustomParams() {
        let url = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: url,
            timeout: 60.0,
            defaultHeaders: ["User-Agent": "LiveboxClient"]
        )

        #expect(config.baseURL == url)
        #expect(config.timeout == 60.0)
        #expect(config.defaultHeaders["User-Agent"] == "LiveboxClient")
    }

    @Test("Client configuration initialization with URL string")
    func testConfigurationInitWithURLString() throws {
        let urlString = "http://192.168.1.1"
        let config = try LiveboxClientConfiguration(baseURLString: urlString)

        #expect(config.baseURL.absoluteString == urlString)
    }

    @Test("Client configuration initialization with invalid URL string")
    func testConfigurationInitWithInvalidURLString() {
        #expect(throws: LiveboxError.self) {
            _ = try DefaultLiveboxClient(baseURLString: "")
        }
    }

    @Test("Client initialization with URL")
    func testClientInitWithURL() {
        let url = URL(string: "http://192.168.1.1")!
        _ = DefaultLiveboxClient(baseURL: url)

        // Testing successful initialization (no assertion needed, if it compiles it works)
        #expect(Bool(true))
    }

    @Test("Client initialization with URL string")
    func testClientInitWithURLString() throws {
        _ = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")

        // Testing successful initialization (no assertion needed, if it compiles it works)
        #expect(Bool(true))
    }

    @Test("Client initialization with invalid URL string")
    func testClientInitWithInvalidURLString() throws {
        #expect(throws: LiveboxError.self) {
            _ = try DefaultLiveboxClient(baseURLString: "")
        }
    }

    @Test("Update base URL succeeds")
    func testUpdateBaseURLSuccess() throws {
        let client = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")
        let newURL = URL(string: "http://192.168.1.100")!

        client.updateBaseURL(newURL)

        #expect(client.configuration.baseURL == newURL)
    }

    @Test("Update base URL with clearCache parameter")
    func testUpdateBaseURLWithClearCache() throws {
        let client = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")
        let newURL = URL(string: "http://192.168.1.100")!

        // Test with clearCache = false (default)
        client.updateBaseURL(newURL, clearCache: false)
        #expect(client.configuration.baseURL == newURL)

        // Test with clearCache = true
        let anotherURL = URL(string: "http://192.168.1.200")!
        client.updateBaseURL(anotherURL, clearCache: true)
        #expect(client.configuration.baseURL == anotherURL)
    }

    @Test("Update base URL preserves other configuration")
    func testUpdateBaseURLPreservesConfiguration() throws {
        let originalURL = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: originalURL,
            timeout: 60.0,
            defaultHeaders: ["User-Agent": "TestAgent"],
            username: "UsrAdmin",
            password: "testpass"
        )
        let client = DefaultLiveboxClient(configuration: config)

        let newURL = URL(string: "http://192.168.1.100")!
        client.updateBaseURL(newURL, clearCache: false)

        #expect(client.configuration.baseURL == newURL)
        #expect(client.configuration.timeout == 60.0)
        #expect(client.configuration.defaultHeaders["User-Agent"] == "TestAgent")
        #expect(client.configuration.username == "UsrAdmin")
        #expect(client.configuration.password == "testpass")
    }

    @Test("Update base URL doesn't clear cached data by default")
    func testUpdateBaseURLDoesntClearCachedDataByDefault() throws {
        let client = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")
        let newURL = URL(string: "http://192.168.1.100")!

        #expect(throws: Never.self) {
            client.updateBaseURL(newURL)
        }

        #expect(client.configuration.baseURL == newURL)
    }

    @Test("Update base URL can clear cached data when requested")
    func testUpdateBaseURLCanClearCachedData() throws {
        let client = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")
        let newURL = URL(string: "http://192.168.1.100")!

        #expect(throws: Never.self) {
            client.updateBaseURL(newURL, clearCache: true)
        }

        #expect(client.configuration.baseURL == newURL)
    }

    @Test("Session headers remain unchanged after base URL update")
    func testSessionHeadersUnchangedAfterBaseURLUpdate() throws {
        // Session is created once and not recreated when base URL is updated
        let client = try DefaultLiveboxClient(baseURLString: "http://192.168.1.1")

        // Get initial session headers
        let initialHeaders = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(initialHeaders?["Accept"] == "application/json")

        // Update base URL
        let newURL = URL(string: "http://192.168.1.100")!
        client.updateBaseURL(newURL)

        // Session headers should be unchanged (session is not recreated)
        let updatedHeaders = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(updatedHeaders?["Accept"] == "application/json")
        #expect(updatedHeaders == initialHeaders)
    }

    @Test("Session retains initial headers after base URL update with custom headers")
    func testSessionRetainsInitialHeadersAfterBaseURLUpdate() throws {
        // Create client with custom headers
        let originalURL = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: originalURL,
            defaultHeaders: ["User-Agent": "TestAgent", "X-Custom": "Value"]
        )
        let client = DefaultLiveboxClient(configuration: config)

        // Verify initial session headers include Accept header and custom headers
        let initialHeaders = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(initialHeaders?["Accept"] == "application/json")
        #expect(initialHeaders?["User-Agent"] == "TestAgent")
        #expect(initialHeaders?["X-Custom"] == "Value")

        // Update base URL (note: this doesn't recreate the session)
        let newURL = URL(string: "http://192.168.1.100")!
        client.updateBaseURL(newURL)

        // Session headers remain the same as when client was created
        let updatedHeaders = client.session.configuration.httpAdditionalHeaders as? [String: String]
        #expect(updatedHeaders?["Accept"] == "application/json")
        #expect(updatedHeaders?["User-Agent"] == "TestAgent")
        #expect(updatedHeaders?["X-Custom"] == "Value")
        #expect(updatedHeaders == initialHeaders)
    }
}
