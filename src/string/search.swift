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

/// Character and substring search
public extension String {

    /// Search for a character in a string
    ///
    /// - parameter character: character to search
    /// - parameter index: (optional) start index, defaults to start or end of string depending on `reverse`
    /// - parameter reverse: (optional) search backwards from the `index` or the end of the string
    /// - returns: `String.Index` if character was found or `nil`
    public func position(character: Character, index: String.Index? = nil, reverse: Bool = false) -> String.Index? {
        if reverse {
            var i = (index == nil) ? self.index(before: self.endIndex) : index!
            while i >= self.startIndex {
                if self.characters[i] == character {
                    return i
                }
                i = self.index(before: i)
            }
        } else {
            var i = (index == nil) ? self.startIndex : index!
            while i < self.endIndex {
                if self.characters[i] == character {
                    return i
                }
                i = self.index(after: i)
            }
        }
        return nil
    }

    /// Return array with string indices of found character positions
    ///
    /// - parameter character: character to search
    /// - returns: array of `String.Index` or empty array if character not found
    public func positions(character: Character) -> [String.Index] {
        var result = Array<String.Index>()
        var p = self.position(character: character)
        while p != nil  {
            result.append(p!)
            p = self.position(character: character, index: self.index(after: p!))
        }
        return result
    }

    /// Search for a substring
    ///
    /// - parameter string: substring to search
    /// - parameter index: (optional) start index, defaults to start or end of string depending on `reverse`
    /// - parameter reverse: (optional) search backwards from the `index` or the end of the string
    /// - returns: `String.Index` if character was found or `nil`
    public func position(string: String, index: String.Index? = nil, reverse: Bool = false) -> String.Index? {
        if self.characters.count < string.characters.count {
            // search term longer than self
            return nil
        }

        if reverse {
            if index != nil && self.distance(from: startIndex, to: index!) < string.characters.count {
                // can not find match because string is too short for match
                return nil
            }

            // start with index/self.endIndex and go back
            var i = (index == nil) ?  self.index(endIndex, offsetBy:  -string.characters.count) : index!
            while i >= self.startIndex {

                var idx = i

                // compare substring
                var match = true
                for character in string.characters {
                    if self.characters[idx] != character {
                        match = false
                        break
                    }
                    idx = self.index(after: idx)
                }
                if match {
                    return i
                }
                i = self.index(before: i)
            }
        } else {
            if index != nil && self.distance(from: index!, to: self.endIndex) < string.characters.count {
                // can not find match because string is too short for match
                return nil
            }
            let start = (index == nil) ? self.startIndex : index!
            var i = start
            // iterate from start to end - search string length
            while i < endIndex {
                var idx = i

                // compare substring
                var match = true
                for character in string.characters {
                    if self.characters[idx] != character {
                        match = false
                        break
                    }
                    idx = self.index(after: idx)
                }
                if match {
                    return i
                }
                i = self.index(after: i)
            }
        }
        return nil
    }

    /// Return array with string indices of found substring positions
    ///
    /// - parameter string: substring to search
    /// - returns: array of `String.Index` or empty array if substring not found
    public func positions(string: String) -> [String.Index] {
        var result = Array<String.Index>()
        var p = self.position(string: string)
        while p != nil  {
            result.append(p!)
            p = self.position(string: string, index: self.index(after: p!))
        }
        return result
    }

    /// Search for a substring
    ///
    /// - parameter string: string to search
    /// - returns: `true` if the string contains the substring
    public func contains(string: String) -> Bool {
        return self.position(string: string) != nil
    }

    /// Search for a character
    ///
    /// - parameter char: character to search
    /// - returns: `true` if the string contains the character
    public func contains(character: Character) -> Bool {
        return self.position(character: character) != nil
    }

#if os(Linux)
    /// Check if a string has a prefix
    ///
    /// - parameter prefix: the prefix to check for
    /// - returns: true if the prefix was an empty string or the string has the prefix
    public func hasPrefix(_ prefix: String) -> Bool {
        if prefix.characters.count == 0 {
            // if the prefix has a length of zero every string is prefixed by that
            return true
        }
        if self.characters.count < prefix.characters.count {
            // if self is shorter than the prefix
            return false
        }
        if prefix.characters.count == 1 {
            // single char prefix is simple
            return self.characters.first! == prefix.characters.first!
        }

        // quick check if first and last char match
        if self.characters.first! == prefix.characters.first! && self.characters[self.index(self.startIndex, offsetBy: prefix.characters.count - 1)] == prefix.characters.last! {
            // if prefix length == 2 instantly return true
            if prefix.characters.count == 2 {
                return true
            }

            // match, thorough check
            var selfIndex = self.index(after:self.startIndex)
            var prefixIndex = prefix.index(after:prefix.startIndex)

            // first and last already checked
            for _ in 1..<(prefix.characters.count - 1) {
                if self.characters[selfIndex] != prefix.characters[prefixIndex] {
                    return false
                }
                selfIndex = self.index(after: selfIndex)
                prefixIndex = prefix.index(after: prefixIndex)
            }
            return true
        }
        return false
    }

    /// Check if a string has a suffix
    ///
    /// - parameter suffix: the suffix to check for
    /// - returns: true if the suffix was an empty string or the string has the suffix
    public func hasSuffix(_ suffix: String) -> Bool {
        if suffix.characters.count == 0 {
            // if the suffix has a length of zero every string is suffixed by that
            return true
        }
        if self.characters.count < suffix.characters.count {
            // if self is shorter than the suffix
            return false
        }
        if suffix.characters.count == 1 {
            // single char prefix is simple
            return self.characters.last! == suffix.characters.first!
        }

        // quick check if first and last char match
        if self.characters.last! == suffix.characters.last! && self.characters[self.index(self.startIndex, offsetBy: self.characters.count - suffix.characters.count)] == suffix.characters.first! {
            // if suffix length == 2 instantly return true
            if suffix.characters.count == 2 {
                return true
            }

            // match, thorough check
            var selfIndex = self.index(self.startIndex, offsetBy: self.characters.count - suffix.characters.count + 1)
            var suffixIndex = suffix.index(after: suffix.startIndex)

            // first and last already checked
            for _ in 1..<(suffix.characters.count - 1) {
                if self.characters[selfIndex] != suffix.characters[suffixIndex] {
                    return false
                }
                selfIndex = self.index(after: selfIndex)
                suffixIndex = suffix.index(after: suffixIndex)
            }
            return true
        }
        return false
    }
#endif
}
