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

public extension String {

    /// Trim whitespace at start and end of string
    ///
    /// - returns: trimmed string
    public func stringByTrimmingWhitespace() -> String {
        var startIndex = self.characters.startIndex
        var index = self.characters.startIndex
        for c in self.characters {
            if !Charset.isUnicodeWhitespaceOrNewline(character: c) {
                startIndex = index
                break
            }
            index = self.index(after: index)
        }

        var endIndex = self.characters.index(before: self.characters.endIndex)
        for _ in 0..<self.characters.count {
            if !Charset.isUnicodeWhitespaceOrNewline(character: self.characters[endIndex]) {
                break
            }
            endIndex = self.characters.index(before: endIndex)
        }

        return self.subString(range: startIndex..<self.characters.index(after: endIndex))
    }
}