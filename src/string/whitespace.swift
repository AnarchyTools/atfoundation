//
//  whitespace.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

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