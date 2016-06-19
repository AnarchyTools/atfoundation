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

/// Random number generators
public protocol RandomNumberGenerator {

	/// Returns byte buffer of random bytes
	///
	/// - parameter count: number of bytes to return
	/// - returns: buffer of random bytes
	static func bytes(count: Int) -> [UInt8]

	/// Return a UInt32 random number
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	static func unsignedNumber(range: CountableRange<UInt32>) -> UInt32

	/// Return a Int32 random number
	///
	/// This may be a bit slower than the unsigned version as we have
	/// to upcast through a 64 bit type to avoid overflows.
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	static func signedNumber(range: CountableRange<Int32>) -> Int32
}

#if os(Linux)

/// Default CSPRNG for linux, uses /dev/urandom, so it needs a file descriptor
public class Random: RandomNumberGenerator {
	static var urandom: ROFile? = nil

	/// Returns byte buffer of random bytes
	///
	/// - parameter count: number of bytes to return
	/// - returns: buffer of random bytes
	public class func bytes(count: Int) -> [UInt8] {
		if let urandom = Random.urandom {
			let result: [UInt8] = try! urandom.read(size: count)
			return result
		} else {
			do {
				Random.urandom = try ROFile(path: Path("/dev/urandom"), binary: true)
			} catch {
				fatalError("Could not open /dev/urandom: \(error)")
			}
			return Random.bytes(count: count)
		}
	}

	/// Return a UInt32 random number
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	public class func unsignedNumber(range: CountableRange<UInt32>) -> UInt32 {
		let bytes = Random.bytes(count: 4)
		var tmp:UInt32 = 0
		tmp += UInt32(bytes[0])
		tmp += UInt32(bytes[1]) << 8
		tmp += UInt32(bytes[2]) << 16
		tmp += UInt32(bytes[3]) << 24
		let result = UInt32(Double(tmp) / Double(UInt32.max) * Double(range.count)) + range.lowerBound
		return result
	}

	/// Return a Int32 random number
	///
	/// This may be a bit slower than the unsigned version as we have
	/// to upcast through a 64 bit type to avoid overflows.
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	public class func signedNumber(range: CountableRange<Int32>) -> Int32 {
		let bytes = Random.bytes(count: 4)
		var tmp:UInt32 = 0
		tmp += UInt32(bytes[0])
		tmp += UInt32(bytes[1]) << 8
		tmp += UInt32(bytes[2]) << 16
		tmp += UInt32(bytes[3]) << 24
		let result = Int32(Int64(Double(tmp) / Double(UInt32.max) * Double(range.count)) + Int64(range.lowerBound))
		return result
	}
}
#endif

#if os(OSX)

/// Default CSPRNG for OSX, uses arc4random
public class Random: RandomNumberGenerator {

	/// Returns byte buffer of random bytes
	///
	/// - parameter count: number of bytes to return
	/// - returns: buffer of random bytes
	public class func bytes(count: Int) -> [UInt8] {
		var bytes = ContiguousArray<UInt8>(repeating: 0, count: count)
		bytes.withUnsafeMutableBufferPointer { (ptr) in
			arc4random_buf(ptr.baseAddress!, ptr.count)
		}
		return Array<UInt8>(bytes)
	}

	/// Return a UInt32 random number
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	public class func unsignedNumber(range: CountableRange<UInt32>) -> UInt32 {
		let result = arc4random_uniform(UInt32(range.count)) + range.lowerBound
		return result
	}

	/// Return a Int32 random number
	///
	/// This may be a bit slower than the unsigned version as we have
	/// to upcast through a 64 bit type to avoid overflows.
	///
	/// - parameter range: Range of generated random number
	/// - returns: random number in `range`
	public class func signedNumber(range: CountableRange<Int32>) -> Int32 {
		let result = Int32(Int64(arc4random_uniform(UInt32(range.count))) + Int64(range.lowerBound))
		return result
	}
}
#endif