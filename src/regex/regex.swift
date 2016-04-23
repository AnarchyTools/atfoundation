//
//  regex.swift
//  SwiftyRegex
//
//  Created by Johannes Schriewer on 06/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

/// internal extension to convert a string to an integer array
extension Sequence where Iterator.Element == CChar {
    static func fromString(_ string: String) -> [CChar] {
        var temp = [CChar]()
        temp.reserveCapacity(string.utf8.count)
        for c in string.utf8 {
            temp.append(CChar(c))
        }
        temp.append(CChar(0))
        return temp
    }
}

/// Regular expression matcher based on pcre
public class RegEx {
    private let compiled: OpaquePointer?

    public let pattern: String
    public let namedCaptureGroups:[String:Int]
    public let numCaptureGroups:Int

    /// Errors that may be thrown by initializer
    public enum Error: ErrorProtocol {
        /// Invalid pattern, contains error offset and error message from pcre engine
        case InvalidPattern(errorOffset: Int, errorMessage: String)
        case UnknownError
    }

    /// Initialize RegEx with pattern
    ///
    /// - parameter pattern: Regular Expression pattern
    /// - throws: RegEx.Error.InvalidPattern when pattern is invalid
    public init(pattern: String) throws {
        self.pattern = pattern

        var tmp = [CChar].fromString(pattern)

        var error = UnsafePointer<CChar>(bitPattern: 0)
        var errorOffset:Int32 = 0
        compiled = pcre_compile(&tmp, 0, &error, &errorOffset, nil)
        if let error = error where compiled == nil {
            let errorMessage = String(validatingUTF8: error)!
            self.namedCaptureGroups = [String:Int]()
            self.numCaptureGroups = 0
            throw RegEx.Error.InvalidPattern(errorOffset: Int(errorOffset), errorMessage: errorMessage)
        }

        // number of capture groups
        var patternCount: Int = 0
        pcre_fullinfo(self.compiled, nil, Int32(PCRE_INFO_CAPTURECOUNT), &patternCount)
        self.numCaptureGroups = patternCount

        // named capture groups
        var named = [String:Int]()
        pcre_fullinfo(self.compiled, nil, Int32(PCRE_INFO_NAMECOUNT), &patternCount)
        if patternCount > 0 {
            var name_table: UnsafeMutablePointer<UInt8>? = nil
            var name_entry_size: Int = 0

            pcre_fullinfo(self.compiled, nil, Int32(PCRE_INFO_NAMETABLE), &name_table)
            pcre_fullinfo(self.compiled, nil, Int32(PCRE_INFO_NAMEENTRYSIZE), &name_entry_size)

            if name_table == nil {
                throw RegEx.Error.UnknownError
            }

            for i: Int in 0..<patternCount {
                let offset = name_entry_size * i
                let num = (Int(name_table![offset]) << 8) + Int(name_table![offset + 1])

                // pattern name
                var patternName = [UInt8](repeating: 0, count: name_entry_size + 1)
                for idx in (name_entry_size * i + 2)..<(name_entry_size * (i + 1)) {
                    patternName[idx - (name_entry_size * i + 2)] = name_table![idx]
                }

                guard let patternNameString = String(validatingUTF8: UnsafePointer<CChar>(patternName)) else {
                    continue
                }

                named[patternNameString] = num
            }
        }
        self.namedCaptureGroups = named
    }

    deinit {
        pcre_free(UnsafeMutablePointer<Void>(self.compiled))
    }

    /// Match a string against the pattern
    ///
    /// - parameter string: the string to match
    /// - returns: tuple with matches, named parameters are returned as numbered matches too
    public func match(_ string: String) -> (numberedParams:[String], namedParams:[String:String]) {
	    var outVector = [Int32](repeating: 0, count: 30)

        let subject = [CChar].fromString(string)

        // pcre_exec does not like zero terminated strings (???)
        let resultCount = pcre_exec(self.compiled, nil, subject, Int32(subject.count-1), 0, 0, &outVector, 30)
        if resultCount < 0 {
            // no match or error
            return ([], [String:String]())
        }

	    if resultCount == 0 {
		    // ovector too small
            // TODO: Avoid this
            return ([], [String:String]())
	    }

        // get numbered results
        var params = [String]()
        for i: Int in 0..<Int(resultCount) {
            let startOffset = outVector[i * 2]
            let length = outVector[i * 2 + 1]

            if length == 0 {
                params.append("")
                continue
            }

            var subString = [CChar](repeating: 0, count: Int(length) + 1)
            for idx in startOffset..<length {
                subString[Int(idx-startOffset)] = subject[Int(idx)]
            }
            if let match = String(validatingUTF8: UnsafePointer<CChar>(subString)) {
                params.append(match)
            }
        }

        // named results
        var named = [String:String]()
        for (grp, num) in self.namedCaptureGroups {
            let startOffset = outVector[2 * num]
            let length = outVector[2 * num + 1]

            if length == 0 {
                named[grp] = ""
                continue
            }

            var subString = [CChar](repeating: 0, count: Int(length) + 1)
            for idx in startOffset..<length {
                subString[Int(idx-startOffset)] = subject[Int(idx)]
            }

            if let match = String(validatingUTF8: UnsafePointer<CChar>(subString)) {
                named[grp] = match
            }
        }

        return (numberedParams: params, namedParams: named)
    }

}
