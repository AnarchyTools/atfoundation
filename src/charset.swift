// # TODO List:
//
// ## Charset class:
//
// - isLetter(character:) -> Bool
// - isUnicodeLetter(character:) -> Bool
// - isNumberDigit(character:) -> Bool
// - isAlphaNumeric(character:) -> Bool
// - isUnicodeAlphaNumeric(character:) -> Bool

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

}