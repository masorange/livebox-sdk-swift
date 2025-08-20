extension String {
    /// Removes all colons from the string.
    /// - Returns: A new string with all colons removed.
    var removingColons: String {
        replacingOccurrences(of: ":", with: "")
    }
}
