//
//  main.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

print("Starting tests...")

XCTMain([
	testCase(SearchTests.allTests),
	testCase(SplitTests.allTests),
	testCase(SubstringTests.allTests),
	testCase(WhitespaceTests.allTests),
	testCase(ReplaceTests.allTests),
    testCase(PathTests.allTests)
])
