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
    import Glibc
#else
    import Darwin
#endif

public protocol Stream: class {
    var fp: UnsafeMutablePointer<FILE>? { get set }
    var fd: Int32 { get }
}

public extension Stream {

    /// fetch a file descriptor for this file
    var fd: Int32 {
        return fileno(self.fp)
    }

    public func closeStream() {
        if let fp = self.fp {
            fclose(fp)
            self.fp = nil
        }
    }
}