// Copyright (c) 2016 Anarchy Tools Contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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