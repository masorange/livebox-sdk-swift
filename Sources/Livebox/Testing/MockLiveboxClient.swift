import Foundation

/// A wrapper to encode any value for JSON serialization
private struct AnyEncodable: Encodable {
    private let encode: (Encoder) throws -> Void

    init<T>(_ wrapped: T) {
        if let encodable = wrapped as? Encodable {
            encode = encodable.encode
        } else {
            encode = { encoder in
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        try encode(encoder)
    }
}

/// A mock implementation of the LiveboxClient protocol for testing purposes.
class MockLiveboxClient: LiveboxClient {
    var configuration: LiveboxClientConfiguration

    /// The current capabilities of the router (mocked).
    private(set) var capabilities: Capabilities?

    /// A dictionary for looking up features by their ID (mocked).
    private(set) var featureLookup: [String: Capabilities.Feature] = [:]

    /// Mock responses for specific endpoints.
    public var mockResponses: [String: Any] = [:]

    /// Mock errors for specific endpoints.
    public var mockErrors: [String: LiveboxError] = [:]

    /// Record of all requests made.
    public private(set) var requestLog: [(endpoint: String, method: HTTPMethod, headers: [String: String]?, body: Data?)] = []

    /// Defines whether fetchCapabilities should succeed or fail.
    var shouldFetchCapabilitiesSucceed = true

    /// The capabilities to return when fetchCapabilities is called.
    public var mockedCapabilities = Capabilities(features: [
        Capabilities.Feature(
            id: "mock.feature.get",
            uri: "/mock/feature/get",
            ops: [.read]),
        Capabilities.Feature(
            id: "mock.feature.post",
            uri: "/mock/feature/post",
            ops: [.add]),
        Capabilities.Feature(
            id: "mock.feature.all",
            uri: "/mock/feature/all",
            ops: Capabilities.Feature.Operation.allCases),
    ])

    init() {
        configuration = try! .init(baseURLString: "http://mock.url")
    }

    @discardableResult
    public func getCapabilities(completion: @escaping (Result<Capabilities, LiveboxError>) -> Void) -> URLSessionDataTask? {
        logRequest(endpoint: "/sysbus/Capabilities:get", method: .post, headers: nil, body: nil)

        if shouldFetchCapabilitiesSucceed {
            self.capabilities = mockedCapabilities
            self.buildFeatureLookup(capabilities: mockedCapabilities)
            completion(.success(mockedCapabilities))
        } else {
            let error = LiveboxError.notImplementedInMock("Capabilities")
            completion(.failure(error))
        }

        return nil
    }

    func buildFeatureLookup(capabilities: Capabilities) {
        var lookup: [String: Capabilities.Feature] = [:]
        for feature in capabilities.features {
            lookup[feature.id] = feature
        }

        featureLookup = lookup
    }

    /// Helper method to record a request.
    private func logRequest(endpoint: String, method: HTTPMethod, headers: [String: String]?, body: Data?) {
        requestLog.append((endpoint: endpoint, method: method, headers: headers, body: body))
    }

    @discardableResult
    public func requestFeature<T: Encodable, U: Decodable>(
        id featureId: FeatureID,
        pathVariables: [String: String],
        method: HTTPMethod,
        headers: [String: String]?,
        body: T?,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        let endpoint = buildEndpoint(featureId: featureId.id, pathVariables: pathVariables)
        logRequest(endpoint: endpoint, method: method, headers: headers, body: nil)

        // Check for mock errors first
        if let error = mockErrors[featureId.id] {
            completion(.failure(error))
            return nil
        }

        // Check for mock responses
        if let response = mockResponses[featureId.id] {
            if let typedResponse = response as? U {
                completion(.success(typedResponse))
            } else {
                // Handle EmptyResponse and Void responses specially
                // EmptyResponse is used internally by the client for operations that don't return data
                // but need to be converted to Void for the public API
                if U.self == EmptyResponse.self {
                    // Create an EmptyResponse instance from empty JSON
                    let emptyResponseData = "{}".data(using: .utf8)!
                    let emptyResponse = try! JSONDecoder().decode(U.self, from: emptyResponseData)
                    completion(.success(emptyResponse))
                } else if String(describing: U.self) == "()" || U.self == Void.self {
                    // Handle Void/() types directly
                    completion(.success(() as! U))
                } else {
                    // Try to convert the response using JSON encoding/decoding
                    do {
                        let jsonData: Data
                        if let encodableResponse = response as? Encodable {
                            jsonData = try JSONEncoder().encode(AnyEncodable(encodableResponse))
                        } else {
                            // Fallback for non-encodable types
                            jsonData = try JSONSerialization.data(withJSONObject: response, options: [])
                        }
                        let decodedResponse = try JSONDecoder().decode(U.self, from: jsonData)
                        completion(.success(decodedResponse))
                    } catch {
                        completion(.failure(LiveboxError.decodingError(error)))
                    }
                }
            }
        } else {
            completion(.failure(LiveboxError.featureNotFound(featureId.id)))
        }

        return nil
    }

    @discardableResult
    public func invokeFeature<T: Encodable>(
        id featureId: FeatureID,
        pathVariables: [String: String],
        headers: [String: String]?,
        body: T?,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        let endpoint = buildEndpoint(featureId: featureId.id, pathVariables: pathVariables)
        logRequest(endpoint: endpoint, method: .post, headers: headers, body: nil)

        // Check for mock errors first
        if let error = mockErrors[featureId.id] {
            completion(.failure(error))
            return nil
        }

        // For invoke operations, we just need to succeed or fail
        if mockResponses[featureId.id] != nil || featureId == .reboot {
            completion(.success(()))
        } else {
            completion(.failure(LiveboxError.featureNotFound(featureId.id)))
        }

        return nil
    }

    /// Updates the authentication credentials for this client.
    /// - Parameters:
    ///   - username: New username for authentication
    ///   - password: New password for authentication
    /// - Throws: An error if the credentials cannot be updated
    public func updateCredentials(username: String?, password: String?) throws(LiveboxError) {
        self.configuration = try LiveboxClientConfiguration(
            baseURLString: configuration.baseURL.absoluteString,
            timeout: configuration.timeout,
            defaultHeaders: configuration.defaultHeaders,
            username: username,
            password: password
        )
    }

    /// Updates the base URL for this client.
    /// - Parameters:
    ///   - baseURL: New base URL for the API
    ///   - clearCache: Whether to clear cached capabilities and feature data (default: false)
    public func updateBaseURL(_ baseURL: URL, clearCache: Bool = false) {
        self.configuration = LiveboxClientConfiguration(
            baseURL: baseURL,
            timeout: configuration.timeout,
            defaultHeaders: configuration.defaultHeaders,
            username: configuration.username,
            password: configuration.password
        )

        // Clear cached capabilities and feature lookup if requested
        if clearCache {
            self.capabilities = nil
            self.featureLookup.removeAll()
        }
    }

    private func buildEndpoint(featureId: String, pathVariables: [String: String]) -> String {
        var endpoint = "/sysbus/\(featureId)"
        for (_, value) in pathVariables {
            endpoint += "/\(value)"
        }
        return endpoint
    }
}
