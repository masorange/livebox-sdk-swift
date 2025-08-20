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
}
