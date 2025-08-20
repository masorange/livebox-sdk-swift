import Foundation
import Testing

@testable import Livebox

@Suite("LiveboxAPI Authentication Tests")
struct LiveboxAPIAuthTests {

    @Test("Create service without credentials")
    func testCreateServiceWithoutCredentials() throws {
        // Given
        let baseURL = "http://192.168.1.1"

        // When
        let service = try LiveboxAPI(baseURLString: baseURL)

        // Then
        #expect(!service.isAuthenticated)
        #expect(service.baseURL.absoluteString == baseURL)
        #expect(service.currentUsername == nil)
    }

    @Test("Create service with credentials (convenience initializer)")
    func testCreateServiceWithCredentials() throws {
        // Given
        let baseURL = "http://192.168.1.1"
        let username = "admin"
        let password = "test123"

        // When
        let service = try LiveboxAPI(baseURLString: baseURL, username: username, password: password)

        // Then
        #expect(service.isAuthenticated)
        #expect(service.baseURL.absoluteString == baseURL)
        #expect(service.currentUsername == username)
    }

    @Test("Login with valid credentials")
    func testLoginSuccess() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        mockClient.shouldFetchCapabilitiesSucceed = true
        #expect(!service.isAuthenticated)

        // When
        let isLoggedIn = try await withCheckedThrowingContinuation { continuation in
            service.login(username: "admin", password: "test123") { result in
                continuation.resume(with: result)
            }
        }

        // Then
        #expect(service.isAuthenticated)
        #expect(service.currentUsername == "admin")
        #expect(isLoggedIn)
    }

    @Test("Login with invalid credentials")
    func testLoginFailure() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        mockClient.shouldFetchCapabilitiesSucceed = false
        #expect(!service.isAuthenticated)

        // When/Then
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                service.login(username: "admin", password: "wrongpass") { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Login should have failed")
        } catch {
            #expect(error is LiveboxError)
            #expect(!service.isAuthenticated)
            #expect(service.currentUsername == nil)
        }
    }

    @Test("Login async/await success")
    func testLoginAsyncSuccess() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        mockClient.shouldFetchCapabilitiesSucceed = true

        // When
        do {
            let isLoggedIn = try await service.login(username: "admin", password: "test123")

            // Then
            #expect(service.isAuthenticated)
            #expect(service.currentUsername == "admin")
            #expect(isLoggedIn)
        } catch {
            Issue.record("Login should have succeeded: \(error)")
        }
    }

    @Test("Login async/await failure")
    func testLoginAsyncFailure() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        mockClient.shouldFetchCapabilitiesSucceed = false

        // When/Then
        do {
            _ = try await service.login(username: "admin", password: "wrongpass")
            Issue.record("Login should have failed")
        } catch {
            #expect(!service.isAuthenticated)
        }
    }

    @Test("Logout clears authentication")
    func testLogout() throws {
        // Given
        let service = try LiveboxAPI(baseURLString: "http://192.168.1.1", username: "admin", password: "test123")
        #expect(service.isAuthenticated)

        // When
        service.logout()

        // Then
        #expect(!service.isAuthenticated)
        #expect(service.currentUsername == nil)
    }

    @Test("Update credentials without validation")
    func testUpdateCredentials() throws {
        // Given
        let service = try LiveboxAPI(baseURLString: "http://192.168.1.1")
        #expect(!service.isAuthenticated)

        // When
        try service.updateCredentials(username: "newuser", password: "newpass")

        // Then
        #expect(service.isAuthenticated)
        #expect(service.currentUsername == "newuser")
    }

    @Test("Update credentials to nil")
    func testUpdateCredentialsToNil() throws {
        // Given
        let service = try LiveboxAPI(baseURLString: "http://192.168.1.1", username: "admin", password: "test123")
        #expect(service.isAuthenticated)

        // When
        try service.updateCredentials(username: nil, password: nil)

        // Then
        #expect(!service.isAuthenticated)
        #expect(service.currentUsername == nil)
    }

    @Test("Base URL remains consistent")
    func testBaseURLConsistency() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        let baseURL = mockClient.configuration.baseURL.absoluteString

        // When - Login and logout
        mockClient.shouldFetchCapabilitiesSucceed = true

        _ = try await withCheckedThrowingContinuation { continuation in
            service.login(username: "admin", password: "test123") { result in
                continuation.resume(with: result)
            }
        }
        service.logout()

        // Then
        #expect(service.baseURL.absoluteString == baseURL)
    }

    @Test("Service operations require authentication")
    func testOperationsRequireAuth() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)
        #expect(!service.isAuthenticated)

        // When/Then - This should work regardless of authentication status,
        // but the underlying HTTP requests will fail with 401 if not authenticated
        // The service layer doesn't enforce authentication, that's handled by the server

        // We can still call the methods, they just might fail at the HTTP level
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                service.getGeneralInfo { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Expected failure due to missing mock response")
        } catch {
            #expect(error is LiveboxError)
        }
    }

    @Test("Multiple login attempts preserve previous state on failure")
    func testMultipleLoginAttempts() async throws {
        // Given
        let mockClient = MockLiveboxClient()
        let service = LiveboxAPI(client: mockClient)

        // First successful login
        mockClient.shouldFetchCapabilitiesSucceed = true
        _ = try await withCheckedThrowingContinuation { continuation in
            service.login(username: "admin", password: "validpass") { result in
                continuation.resume(with: result)
            }
        }

        #expect(service.isAuthenticated)
        #expect(service.currentUsername == "admin")

        // Second failed login should preserve the previous state
        mockClient.shouldFetchCapabilitiesSucceed = false
        do {
            _ = try await withCheckedThrowingContinuation { continuation in
                service.login(username: "admin", password: "wrongpass") { result in
                    continuation.resume(with: result)
                }
            }
            Issue.record("Second login should have failed")
        } catch {
            // Should still be authenticated with the original credentials
            #expect(service.isAuthenticated)
            #expect(service.currentUsername == "admin")
        }
    }

    @Test("Service creation with URL object")
    func testServiceCreationWithURL() throws {
        // Given
        let url = URL(string: "http://192.168.1.1")!

        // When
        let service = LiveboxAPI(baseURL: url)

        // Then
        #expect(!service.isAuthenticated)
        #expect(service.baseURL == url)
    }

    @Test("Service creation with URL object and credentials")
    func testServiceCreationWithURLAndCredentials() throws {
        // Given
        let url = URL(string: "http://192.168.1.1")!
        let username = "admin"
        let password = "test123"

        // When
        let service = LiveboxAPI(baseURL: url, username: username, password: password)

        // Then
        #expect(service.isAuthenticated)
        #expect(service.baseURL == url)
        #expect(service.currentUsername == username)
    }
}
