import Foundation

/// The main client for interacting with Livebox routers.
/// This class provides methods for making HTTP requests to the router's API.
class DefaultLiveboxClient: LiveboxClient {
    /// The client's configuration.
    var configuration: LiveboxClientConfiguration

    /// The URL session used for making network requests.
    internal let session: URLSession

    /// The capabilities of the router.
    private var capabilities: Capabilities?

    /// A lookup table for features, indexed by their ID.
    private var featureLookup: [String: Capabilities.Feature] = [:]

    /// Creates a new Livebox client with the specified configuration.
    /// - Parameter configuration: The configuration to use for the client.
    init(configuration: LiveboxClientConfiguration) {
        self.configuration = configuration

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeout
        sessionConfig.timeoutIntervalForResource = configuration.timeout
        sessionConfig.httpAdditionalHeaders = configuration.defaultHeaders.merging(["Accept": "application/json"]) { _, new in
            new
        }

        self.session = URLSession(configuration: sessionConfig)
    }

    /// Creates a new Livebox client with authentication.
    /// - Parameters:
    ///   - baseURL: The base URL to use for the API.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    convenience init(baseURL: URL, username: String? = nil, password: String? = nil) {
        self.init(configuration: LiveboxClientConfiguration(baseURL: baseURL, username: username, password: password))
    }

    /// Creates a new Livebox client with authentication and a base URL string.
    /// - Parameters:
    ///   - baseURLString: The base URL string to use for the API.
    ///   - username: Username for HTTP Basic Authentication. Default is nil.
    ///   - password: Password for HTTP Basic Authentication. Default is nil.
    /// - Throws: An error if the baseURLString is not a valid URL.
    convenience init(baseURLString: String, username: String? = nil, password: String? = nil) throws(LiveboxError) {
        self.init(configuration: try LiveboxClientConfiguration(baseURLString: baseURLString, username: username, password: password))
    }

    /// Makes a request to the specified endpoint.
    /// - Parameters:
    ///   - endpoint: The endpoint to make the request to, relative to the base URL.
    ///   - method: The HTTP method to use for the request. Defaults to GET.
    ///   - headers: Additional headers to include with the request. These are merged with the default headers.
    ///   - body: The body of the request. This is encoded to JSON. Pass nil for no body (e.g., for GET requests).
    ///   - completion: A callback to invoke when the request completes, with either a response or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request.
    @discardableResult
    func request<T: Encodable, U: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        body: T? = nil,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        guard var urlComponents = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: false) else {
            completion(.failure(LiveboxError.invalidURL(configuration.baseURL.absoluteString)))
            return nil
        }

        // Append the endpoint path to the base URL path
        let path = urlComponents.path.appending("/\(endpoint)".replacingOccurrences(of: "//", with: "/"))
        urlComponents.path = path

        guard let url = urlComponents.url else {
            completion(.failure(LiveboxError.invalidURL("\(configuration.baseURL.absoluteString)/\(endpoint)")))
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add default headers
        for (key, value) in configuration.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add Basic Authentication header if credentials are provided
        if let username = configuration.username, let password = configuration.password {
            let credentials = "\(username):\(password)"
            if let credentialsData = credentials.data(using: .utf8) {
                let base64Credentials = credentialsData.base64EncodedString()
                request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            }
        }

        // Add request-specific headers
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        // Add body if provided
        if let body = body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(LiveboxError.encodingError(error)))
                return nil
            }
        }

        // Log the request if logging is enabled
        let requestStartTime = CFAbsoluteTimeGetCurrent()
        if LiveboxConfiguration.shared.isLoggingEnabled {
            LiveboxConfiguration.shared.logger.logRequest(request, body: request.httpBody, level: .info)
        }

        let task = session.dataTask(with: request) { data, response, error in
            let responseTime = CFAbsoluteTimeGetCurrent()

            // Log the response if logging is enabled
            if LiveboxConfiguration.shared.isLoggingEnabled {
                let metrics = HTTPMetrics(
                    requestStartTime: requestStartTime,
                    responseTime: responseTime,
                    statusCode: (response as? HTTPURLResponse)?.statusCode,
                    requestBodySize: request.httpBody?.count ?? 0,
                    responseBodySize: data?.count ?? 0,
                    hadError: error != nil
                )

                let logLevel: LiveboxLogLevel
                if error != nil {
                    logLevel = .error
                } else if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        logLevel = .info
                    case 400...499:
                        logLevel = .error
                    case 500...599:
                        logLevel = .fault
                    default:
                        logLevel = .default
                    }
                } else {
                    logLevel = .info
                }

                LiveboxConfiguration.shared.logger.logResponse(
                    response as? HTTPURLResponse,
                    data: data,
                    error: error,
                    level: logLevel,
                    metrics: metrics
                )
            }

            if let error = error {
                completion(.failure(LiveboxError.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(LiveboxError.unexpectedResponse))
                return
            }

            if httpResponse.statusCode == 401 {
                completion(.failure(LiveboxError.authenticationRequired))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(LiveboxError.httpError(httpResponse.statusCode, data)))
                return
            }

            guard let data = data else {
                completion(.failure(LiveboxError.noData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(U.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(LiveboxError.decodingError(error)))
            }
        }

        task.resume()
        return task
    }

    /// Makes a request with no request body.
    @discardableResult
    func request<U: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        headers: [String: String]? = nil,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        let emptyBody: EmptyBody? = nil
        return request(endpoint, method: method, headers: headers, body: emptyBody, completion: completion)
    }

    /// Fetches the capabilities of the router.
    /// - Parameter completion: A callback to invoke when the operation completes, with either the capabilities or an error.
    /// - Returns: A URLSessionDataTask that can be used to cancel the request.
    @discardableResult
    func getCapabilities(completion: @escaping (Result<Capabilities, LiveboxError>) -> Void) -> URLSessionDataTask? {
        // The capabilities endpoint is always at /API/Capabilities
        let capabilitiesEndpoint = "/API/Capabilities"

        return request(capabilitiesEndpoint) { [weak self] (result: Result<Capabilities, LiveboxError>) in
            switch result {
            case .success(let capabilities):
                self?.capabilities = capabilities

                // Build a lookup table for easier feature access
                self?.buildFeatureLookup(capabilities: capabilities)

                completion(.success(capabilities))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Builds a lookup table for features, indexed by their ID.
    /// - Parameter capabilities: The capabilities to build the lookup table from.
    private func buildFeatureLookup(capabilities: Capabilities) {
        for feature in capabilities.features {
            featureLookup[feature.id] = feature
        }
    }

    /// Gets a feature by its ID.
    /// - Parameter featureId: The ID of the feature to get.
    /// - Returns: The feature, or nil if it doesn't exist.
    func getFeature(id featureId: FeatureID) -> Capabilities.Feature? {
        return featureLookup[featureId.id]
    }

    /// Checks if a feature exists and supports the specified operation.
    /// - Parameters:
    ///   - featureId: The ID of the feature to check.
    ///   - operation: The operation to check for.
    /// - Returns: True if the feature exists and supports the operation, false otherwise.
    func supportsFeature(id featureId: FeatureID, operation: Capabilities.Feature.Operation) -> Bool {
        guard let feature = getFeature(id: featureId) else {
            return false
        }

        return feature.supports(operation: operation)
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
    @discardableResult
    func requestFeature<T: Encodable, U: Decodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: T? = nil,
        completion: @escaping (Result<U, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        guard let feature = getFeature(id: featureId) else {
            completion(.failure(LiveboxError.featureNotFound(featureId.id)))
            return nil
        }

        // Check if the operation is supported
        let requiredOperation: Capabilities.Feature.Operation
        switch method {
        case .get:
            requiredOperation = .read
        case .post:
            requiredOperation = pathVariables.isEmpty ? .invoke : .add
        case .put, .patch:
            requiredOperation = .write
        case .delete:
            requiredOperation = .delete
        default:
            requiredOperation = .read
        }

        if !feature.supports(operation: requiredOperation) {
            completion(.failure(LiveboxError.operationNotSupported(featureId.id, String(describing: requiredOperation))))
            return nil
        }

        // Build the path

        if feature.getPathVariableNames().sorted() != pathVariables.keys.sorted() {
            completion(
                .failure(
                    LiveboxError.invalidPathVariables(
                        featureId: featureId.id,
                        requiredVariables: feature.getPathVariableNames().joined(separator: ", "),
                        providedVariables: pathVariables
                    )
                )
            )
            return nil
        }

        let path = feature.getPath(pathVariables: pathVariables)

        // Make the request
        return request(path, method: method, headers: headers, body: body, completion: completion)
    }

    /// Invokes a feature that supports the invoke operation.
    @discardableResult
    func invokeFeature<T: Encodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        headers: [String: String]? = nil,
        body: T? = nil,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        guard let feature = getFeature(id: featureId) else {
            completion(.failure(LiveboxError.featureNotFound(featureId.id)))
            return nil
        }

        if !feature.supports(operation: .invoke) {
            completion(.failure(LiveboxError.operationNotSupported(featureId.id, "invoke")))
            return nil
        }

        if let body = body {
            return requestFeatureWithoutResponse(
                id: featureId,
                pathVariables: pathVariables,
                method: .post,
                headers: headers,
                body: body,
                completion: completion
            )
        } else {
            return requestFeatureWithoutResponse(
                id: featureId,
                pathVariables: pathVariables,
                method: .post,
                headers: headers,
                completion: completion
            )
        }
    }

    /// Makes a request to a feature endpoint with no request body.
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

    /// Makes a request to a feature endpoint with a body but no expected response data.
    @discardableResult
    func requestFeatureWithoutResponse<T: Encodable>(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        method: HTTPMethod,
        headers: [String: String]? = nil,
        body: T,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        return requestFeature(
            id: featureId,
            pathVariables: pathVariables,
            method: method,
            headers: headers,
            body: body
        ) { (result: Result<EmptyResponse, LiveboxError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Makes a request to a feature endpoint with no body and no expected response data.
    @discardableResult
    func requestFeatureWithoutResponse(
        id featureId: FeatureID,
        pathVariables: [String: String] = [:],
        method: HTTPMethod,
        headers: [String: String]? = nil,
        completion: @escaping (Result<Void, LiveboxError>) -> Void
    ) -> URLSessionDataTask? {
        return requestFeature(
            id: featureId,
            pathVariables: pathVariables,
            method: method,
            headers: headers
        ) { (result: Result<EmptyResponse, LiveboxError>) in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Updates the authentication credentials for this client.
    /// - Parameters:
    ///   - username: New username for authentication
    ///   - password: New password for authentication
    /// - Throws: An error if the credentials cannot be updated
    func updateCredentials(username: String?, password: String?) throws(LiveboxError) {
        self.configuration = LiveboxClientConfiguration(
            baseURL: configuration.baseURL,
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
    func updateBaseURL(_ baseURL: URL, clearCache: Bool = false) {
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
}
