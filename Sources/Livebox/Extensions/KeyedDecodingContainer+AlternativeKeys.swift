import Foundation

/// Extension to support alternative keys when decoding JSON with inconsistent key naming.
///
/// This is useful for handling different router manufacturers that may use different
/// capitalizations for the same field (e.g., "idx" vs "Idx", "Manufacturer" vs "ManuFacturer").
extension KeyedDecodingContainer {
    /// Decodes a value for the first key that exists in the container.
    ///
    /// Attempts to decode using each provided key in order until one succeeds.
    /// Throws an error if none of the keys exist or if decoding fails for all keys.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - keys: One or more keys to try, in order of preference.
    /// - Returns: The decoded value.
    /// - Throws: `DecodingError.keyNotFound` if none of the keys exist,
    ///           or other decoding errors if the value cannot be decoded.
    ///
    /// Example:
    /// ```swift
    /// enum CodingKeys: String, CodingKey {
    ///     case manufacturer = "Manufacturer"
    ///     case manufacturerAlt = "ManuFacturer"
    /// }
    ///
    /// // Try "Manufacturer" first, then "ManuFacturer" as fallback
    /// manufacturer = try container.decode(String.self, forFirstOf: .manufacturer, .manufacturerAlt)
    /// ```
    func decode<T: Decodable>(_ type: T.Type, forFirstOf keys: Key...) throws -> T {
        var lastError: Error?

        for key in keys {
            do {
                return try decode(T.self, forKey: key)
            } catch {
                lastError = error
                continue
            }
        }

        // If we get here, none of the keys worked
        let context = DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Could not decode \(type) for any of the keys: \(keys.map { $0.stringValue }.joined(separator: ", "))"
        )
        throw lastError ?? DecodingError.keyNotFound(keys[0], context)
    }

    /// Decodes an optional value for the first key that exists in the container.
    ///
    /// Attempts to decode using each provided key in order until one succeeds.
    /// Returns `nil` if none of the keys exist or if the value is `null`.
    ///
    /// - Parameters:
    ///   - type: The type to decode.
    ///   - keys: One or more keys to try, in order of preference.
    /// - Returns: The decoded value, or `nil` if none of the keys exist or the value is `null`.
    ///
    /// Example:
    /// ```swift
    /// enum CodingKeys: String, CodingKey {
    ///     case idx = "idx"
    ///     case idxAlt = "Idx"
    /// }
    ///
    /// // Try "idx" first, then "Idx" as fallback
    /// idx = container.decodeIfPresent(String.self, forFirstOf: .idx, .idxAlt)
    /// ```
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forFirstOf keys: Key...) -> T? {
        for key in keys {
            if let value = try? decodeIfPresent(T.self, forKey: key) {
                return value
            }
        }
        return nil
    }
}
