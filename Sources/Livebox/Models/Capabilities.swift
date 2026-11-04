import Foundation

/// The capabilities of a router, as returned by the `/API/Capabilities` endpoint.
///
/// The capabilities list every feature the router supports, with its URI and the operations allowed on it.
/// The SDK uses them to build the URL of each request.
public struct Capabilities: Codable {
    /// The list of features available on the router.
    public let features: [Feature]

    private enum CodingKeys: String, CodingKey {
        case features = "Features"
    }
}

extension Capabilities {
    /// Represents a feature (resource) available on the router.
    public struct Feature: Codable, Equatable {
        /// The unique identifier of the feature. See ``FeatureID`` for the known values.
        public let id: String

        /// The URI of the feature. It can contain path variables, such as `{wlan_ifc}`.
        public let uri: String

        /// The operations that can be performed on this feature.
        public let ops: [Operation]

        private enum CodingKeys: String, CodingKey {
            case id = "Id"
            case uri = "Uri"
            case ops = "Ops"
        }

        /// Creates a full path for this feature by replacing path variables with actual values.
        /// - Parameter pathVariables: A dictionary mapping path variable names to their values. For example, `["wlan_ifc": "2.4GHz"]`.
        /// - Returns: The full path with variables replaced by their values.
        public func getPath(pathVariables: [String: String] = [:]) -> String {
            var path = uri
            for (name, value) in pathVariables {
                path = path.replacingOccurrences(of: "{\(name)}", with: value)
            }
            return path
        }

        /// Checks if the feature supports a specific operation.
        /// - Parameter operation: The operation to check for.
        /// - Returns: `true` if the operation is supported, `false` otherwise.
        public func supports(operation: Operation) -> Bool {
            return ops.contains(operation)
        }

        /// Extracts path variable names from the URI.
        /// - Returns: The path variable names found in the URI, without braces. For example, `["wlan_ifc", "wlan_ap"]`.
        public func getPathVariableNames() -> [String] {
            let pattern = "\\{([^\\}]+)\\}"
            let regex = try? NSRegularExpression(pattern: pattern)
            let nsString = uri as NSString
            let results =
                regex?.matches(in: uri, range: NSRange(location: 0, length: nsString.length)) ?? []
            return results.map { nsString.substring(with: $0.range(at: 1)) }
        }
    }
}

extension Capabilities.Feature {
    /// Represents an operation that can be performed on a feature.
    public enum Operation: String, Codable, CaseIterable {
        /// Read operation - resource can be read.
        case read = "R"

        /// Write operation - resource can be modified.
        case write = "W"

        /// Invoke operation - action can be triggered.
        case invoke = "I"

        /// Add operation - new child resources can be added.
        case add = "A"

        /// Delete operation - resource can be deleted.
        case delete = "D"

        /// Query operation - resource description can be read.
        case query = "Q"
    }
}
