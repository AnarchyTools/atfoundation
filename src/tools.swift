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

#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin
#endif

// So apparently this is how you access a fixed length C array from
// an imported struct -.-
public func fixedCArrayToArray<T, E>(data: inout T) -> [E] {
    return withUnsafePointer(&data) { ptr -> [E] in
        let buffer = UnsafeBufferPointer(
            start: unsafeBitCast(ptr, to: UnsafePointer<E>.self),
            count: sizeofValue(data)
        )
        return [E](buffer)
    }
}

/// internal extension to convert a string to an integer array
public extension Sequence where Iterator.Element == CChar {
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