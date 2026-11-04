/// A property wrapper that decodes an optional integer sent either as a number or as a string.
///
/// Some routers (such as ZTE) send numeric values as strings, for example `"3600"` instead of `3600`.
/// The value is always encoded as a number.
@propertyWrapper
public struct FlexibleInt: Codable {
    /// The decoded integer, or `nil` if the value was `null`.
    public var wrappedValue: Int?

    /// Creates a wrapper with the given value.
    /// - Parameter wrappedValue: The integer to wrap.
    public init(wrappedValue: Int?) {
        self.wrappedValue = wrappedValue
    }

    /// Decodes an integer from a number, a numeric string or `null`.
    /// - Throws: `DecodingError.dataCorrupted` if the value is neither a number nor a numeric string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            wrappedValue = intValue
        } else if let stringValue = try? container.decode(String.self), let intValue = Int(stringValue) {
            wrappedValue = intValue
        } else if container.decodeNil() {
            wrappedValue = nil
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected Int or String convertible to Int, but found invalid value"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
