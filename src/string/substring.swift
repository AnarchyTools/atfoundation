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

/// Substring creation
public extension String {

    /// Create substring from string
    ///
    /// - parameter range: range of the substring, will be clamped to `self.endIndex`
    /// - returns: substring or `nil` if start index out of range
    public func subString(range: Range<String.Index>) -> String {
        var result = ""
        result.reserveCapacity(range.count)
        for idx in range {
            result.append(self.characters[idx])
        }
        return result
    }

    /// Create substring from start to index
    ///
    /// - parameter index: end index, excluded
    /// - returns: substring
    public func subString(toIndex index: String.Index) -> String {
        return self.subString(range: self.startIndex..<index)
    }

    /// Create substring from index to end
    ///
    /// - parameter index: start index, included
    /// - returns: substring or `nil` if start index out of range
    public func subString(fromIndex index: String.Index) -> String {
        return self.subString(range: index..<self.endIndex)
    }
}
