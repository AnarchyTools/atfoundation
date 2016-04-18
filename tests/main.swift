//
//  main.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

print("Starting tests...")

XCTMain(testCases: [
	testCase(allTests: SearchTests.allTests),
	testCase(allTests: SplitTests.allTests),
	testCase(allTests: SubstringTests.allTests),
	testCase(allTests: WhitespaceTests.allTests),
	testCase(allTests: ReplaceTests.allTests),
    testCase(allTests: PathTests.allTests)
])
