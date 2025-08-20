import Foundation

/// Represents errors that can occur when interacting with the Livebox API.
public enum LiveboxError: Error {
    /// The provided URL string is not a valid URL.
    case invalidURL(String)

    /// An error occurred while encoding the request body.
    case encodingError(Error)

    /// An error occurred while decoding the response.
    case decodingError(Error)

    /// No data was returned from the server.
    case noData

    /// An unexpected response was received from the server.
    case unexpectedResponse

    /// An HTTP error occurred with the given status code.
    case httpError(Int, Data?)

    /// A network error occurred during the request.
    case networkError(Error)

    /// Authentication is required but not provided or is invalid.
    case authenticationRequired

    /// The requested feature was not found in the router's capabilities.
    case featureNotFound(String)

    /// The requested path variables are invalid.
    case invalidPathVariables(featureId: String, requiredVariables: String, providedVariables: [String: String])

    /// The requested operation is not supported by the feature.
    case operationNotSupported(String, String)

    /// A feature is not implemented in the mock implementation.
    case notImplementedInMock(String)
}

extension LiveboxError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .encodingError(let error):
            return "Failed to encode request body: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        case .unexpectedResponse:
            return "Received an unexpected response from the server"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationRequired:
            return "Authentication is required"
        case .featureNotFound(let featureId):
            return "Feature not found: \(featureId)"
        case .invalidPathVariables(let featureId, let requiredVariables, let providedVariables):
            return "Invalid path variables for \(featureId): \(providedVariables). Required variables: \(requiredVariables)"
        case .operationNotSupported(let featureId, let operation):
            return "Operation \(operation) not supported by feature \(featureId)"
        case .notImplementedInMock(let featureId):
            return "Feature \(featureId) is not implemented in the mock implementation"
        }
    }
}
