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

public class Charset {

    public class func isWhitespace(character: Character) -> Bool {
        switch character {
            case " ", "\n", "\r\n", "\t": // ASCII
                return true
            default:
                return false
        }
    }

    public class func isUnicodeWhitespace(character: Character) -> Bool {
        switch character {
            case " ", "\n", "\r\n", "\t": // ASCII
                return true
            case "\u{2028}", "\u{2029}": // Unicode paragraph seperators
                return true
            case "\u{00a0}", "\u{1680}", "\u{2000}"..."\u{200a}", "\u{202f}", "\u{205f}", "\u{3000}": // various spaces
                return true
            default:
                return false
        }
    }

    public class func isLetter(character: Character) -> Bool {
        switch character {
            case Character("a")...Character("z"):
                return true
            case Character("A")...Character("Z"):
                return true
            default:
                return false
        }
    }

    public class func isNumberDigit(character: Character) -> Bool {
        switch character {
            case Character("0")...Character("9"):
                return true
            default:
                return false
        }
    }

    public class func isAlphaNumeric(character: Character) -> Bool {
        return Charset.isLetter(character: character) || Charset.isNumberDigit(character: character)
    }

    // - isUnicodeLetter(character:) -> Bool
    // - isUnicodeAlphaNumeric(character:) -> Bool
}