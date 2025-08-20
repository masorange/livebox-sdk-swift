import Foundation

public protocol LiveboxClient {
    /// The client's configuration.
    var configuration: LiveboxClientConfiguration { get }

    /// Makes a request to a feature endpoint.
    /// - Parameters:
    ///   - featureId: The ID of the feature to request.
    ///   - pathVariables: A dictionary mapping path variable names to their values.
    ///   - method: The HTTP method to use for the request.
    ///   - headers: Additional headers to include with the request.
    ///   - body: The body of the request. This is encoded to JSON.
    ///   - completion: A callback to invoke when the request completes, with either a response or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or nil if the feature doesn't exist.
    func requestFeature<T: Encodable, U: Decodable>(
        id featureId: FeatureID,
        pathVariables: [String: String],
        method: HTTPMethod,
        headers: [String: String]?,
        body: T?,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask?

    /// Invokes a feature that supports the invoke operation.
    /// - Parameters:
    ///   - featureId: The ID of the feature to invoke.
    ///   - pathVariables: A dictionary mapping path variable names to their values.
    ///   - headers: Additional headers to include with the request.
    ///   - body: The body of the request. This is encoded to JSON.
    ///   - completion: A callback to invoke when the request completes, with either a response or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or nil if the feature doesn't exist.
    func invokeFeature<T: Encodable>(
        id featureId: FeatureID,
        pathVariables: [String: String],
        headers: [String: String]?,
        body: T?,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask?

    /// Fetches the capabilities of the router.
    /// - Parameter completion: A callback to invoke when the operation completes, with either the capabilities or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request.
    func getCapabilities(completion: @escaping (Result<Capabilities, LiveboxError>) -> Void) -> URLSessionDataTask?

    /// Updates the authentication credentials for this client.
    /// - Parameters:
    ///   - username: New username for authentication
    ///   - password: New password for authentication
    /// - Throws: An error if the credentials cannot be updated
    func updateCredentials(username: String?, password: String?) throws(LiveboxError)

    /// Updates the base URL for this client.
    /// - Parameters:
    ///   - baseURL: New base URL for the API
    ///   - clearCache: Whether to clear cached capabilities and feature data (default: false)
    func updateBaseURL(_ baseURL: URL, clearCache: Bool)
}

extension LiveboxClient {
    /// Updates the base URL for this client with default parameters.
    /// - Parameter baseURL: New base URL for the API
    /// - Throws: An error if the URL cannot be updated
    func updateBaseURL(_ baseURL: URL) {
        updateBaseURL(baseURL, clearCache: false)
    }

    /// Makes a request to a feature endpoint.
    /// - Parameters:
    ///   - featureId: The ID of the feature to request.
    ///   - pathVariables: A dictionary mapping path variable names to their values.
    ///   - method: The HTTP method to use for the request.
    ///   - headers: Additional headers to include with the request.
    ///   - body: The body of the request. This is encoded to JSON.
    ///   - completion: A callback to invoke when the request completes, with either a response or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or nil if the feature doesn't exist.
    func requestFeature<T: Encodable, U: Decodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        method: HTTPMethod,
        body: T? = nil,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        requestFeature(
            id: featureId,
            pathVariables: pathVariables,
            method: method,
            headers: nil,
            body: body,
            completion: completion
        )
    }

    /// Makes a request to a feature endpoint with no request body.
    /// - Parameters:
    ///   - featureId: The ID of the feature to request.
    ///   - pathVariables: A dictionary mapping path variable names to their values.
    ///   - method: The HTTP method to use for the request.
    ///   - headers: Additional headers to include with the request.
    ///   - completion: A callback to invoke when the request completes, with either a response or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request, or nil if the feature doesn't exist.
    @discardableResult
    func requestFeature<U: Decodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        method: HTTPMethod,
        headers: [String: String]? = nil,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        let emptyBody: EmptyBody? = nil
        return requestFeature(
            id: featureId,
            pathVariables: pathVariables,
            method: method,
            headers: headers,
            body: emptyBody,
            completion: completion
        )
    }

    /// Invokes a feature that supports the invoke operation.
    func invokeFeature<T: Encodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        headers: [String: String]? = nil,
        body: T? = nil,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        invokeFeature(
            id: featureId,
            pathVariables: pathVariables,
            headers: headers,
            body: body,
            completion: completion
        )
    }
}

/// Represents HTTP methods used for requests.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"
}

/// An empty struct used for requests that don't need a body.
struct EmptyBody: Encodable {}

/// An empty struct used for responses that don't have any data.
struct EmptyResponse: Decodable {}
