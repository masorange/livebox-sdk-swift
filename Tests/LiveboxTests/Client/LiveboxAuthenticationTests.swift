import Foundation
import Testing

@testable import Livebox

@Suite("LiveboxService Authentication Tests")
struct LiveboxAuthenticationTests {

    @Test("LiveboxClient Configuration with authentication")
    func testClientConfigurationWithAuth() {
        let url = URL(string: "http://192.168.1.1")!
        let config = LiveboxClientConfiguration(
            baseURL: url,
            username: "UsrAdmin",
            password: "testpass"
        )

        #expect(config.baseURL == url)
        #expect(config.username == "UsrAdmin")
        #expect(config.password == "testpass")
    }

    @Test("LiveboxClient initialization with authentication")
    func testClientInitWithAuth() throws {
        let url = URL(string: "http://192.168.1.1")!
        let client = LiveboxClientFactory.createClient(baseURL: url, username: "UsrAdmin", password: "testpass")

        #expect(client.configuration.baseURL == url)
        #expect(client.configuration.username == "UsrAdmin")
        #expect(client.configuration.password == "testpass")
    }

    @Test("LiveboxClient initialization with authentication and URL string")
    func testClientInitWithAuthAndURLString() throws {
        let urlString = "http://192.168.1.1"
        let client = try LiveboxClientFactory.createClient(
            baseURLString: urlString,
            username: "UsrAdmin",
            password: "testpass"
        )

        #expect(client.configuration.baseURL.absoluteString == urlString)
        #expect(client.configuration.username == "UsrAdmin")
        #expect(client.configuration.password == "testpass")
    }

    @Test("Configuration init with invalid URL string throws error")
    func testConfigurationInitWithInvalidURL() {
        #expect(throws: LiveboxError.self) {
            _ = try LiveboxClientFactory.createClient(baseURLString: "")
        }
    }
}
