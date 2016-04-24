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
        var startIndex:String.CharacterView.Index = self.startIndex
        for (index, c) in self.characters.enumerated() {
            if !Charset.isUnicodeWhitespace(character: c) {
                startIndex = self.startIndex.advanced(by: index)
                break
            }
        }

        var endIndex = self.endIndex.advanced(by: -1)
        for _ in 0..<self.characters.count {
            if !Charset.isUnicodeWhitespace(character: self.characters[endIndex]) {
                break
            }
            endIndex = endIndex.advanced(by: -1)
        }

        return self.subString(range: startIndex...endIndex)
    }
}