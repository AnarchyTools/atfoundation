//
//  replace.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

/// String replacement functions
public extension String {

    /// Return new string with `range` replaced by `replacement`
    ///
    /// - parameter range: range to replace
    /// - parameter replacement: replacement
    /// - returns: new string with substituted range
    public func replacing(range: Range<String.Index>, replacement: String) -> String {
        let before = self.subString(range: self.startIndex..<range.startIndex)
        let after = self.subString(range: range.endIndex..<self.endIndex)
        return String.join(parts: [before, after], delimiter: replacement)
    }

    /// Search for a substring and replace with other string
    ///
    /// - parameter searchTerm: substring to search
    /// - parameter replacement: replacement to substitute
    /// - returns: new string with applied substitutions
    public func replacing(searchTerm: String, replacement: String) -> String {
        if searchTerm.characters.count == 0 {
            return self
        }
        let comps = self.split(string: searchTerm)
        var replaced = String.join(parts: comps, delimiter: replacement)
        if self.hasSuffix(searchTerm) {
            replaced = replaced.subString(toIndex: replaced.endIndex.advanced(by: -searchTerm.characters.count)) + replacement
        }
        return replaced
    }

    /// Replace `range` in string with substitute, modifies self
    ///
    /// - parameter range: range to replace
    /// - parameter replacement: substitute
    public mutating func replace(range: Range<String.Index>, replacement: String) {
        self = self.replacing(range: range, replacement: replacement)
    }

    /// Replace substring in string, modifies self
    ///
    /// - parameter searchTerm: string to replace
    /// - parameter replacement: substitute
    public mutating func replace(searchTerm: String, replacement: String) {
        if searchTerm.characters.count == 0 {
            return
        }

        self = self.replacing(searchTerm: searchTerm, replacement: replacement)
    }

}