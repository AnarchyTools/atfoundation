public protocol RandomNumberGenerator {
	static func bytes(count: Int) -> [UInt8]
	static func unsignedNumber(range: CountableRange<UInt32>) -> UInt32
	static func signedNumber(range: CountableRange<Int32>) -> Int32
}

#if os(Linux)
public class Random: RandomNumberGenerator {
	static var urandom: ROFile? = nil

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
public class Random: RandomNumberGenerator {
	public class func bytes(count: Int) -> [UInt8] {
		var bytes = ContiguousArray<UInt8>(repeating: 0, count: count)
		bytes.withUnsafeMutableBufferPointer { (ptr) in
			arc4random_buf(ptr.baseAddress!, ptr.count)
		}
		return Array<UInt8>(bytes)
	}

	public class func unsignedNumber(range: CountableRange<UInt32>) -> UInt32 {
		let result = arc4random_uniform(UInt32(range.count)) + range.lowerBound
		return result
	}

	public class func signedNumber(range: CountableRange<Int32>) -> Int32 {
		let result = Int32(Int64(arc4random_uniform(UInt32(range.count))) + Int64(range.lowerBound))
		return result
	}
}
#endif