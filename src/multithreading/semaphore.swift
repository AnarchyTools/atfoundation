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

/// Semaphore primitive
final public class Semaphore {
    private var semaphoreID: UnsafeMutablePointer<sem_t>?

    /// Name of the semaphore
    public let name: String

    /// Initialize a semaphore
    ///
    /// - parameter name: The name
    /// - parameter count: Resource allocation limit
    public init(name: String, count: UInt32) throws {
        self.name = name
        self.semaphoreID = sem_open(name, O_CREAT)
        guard let _ = self.semaphoreID else {
            throw SysError(errno: errno)
        }
    }

    deinit {
        sem_unlink(name)
    }

    /// Wait for a semaphore. This decrements the resource limit,
    /// if the limit reaches zero the thread will wait for a `post()`
    /// from another thread.
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    public func wait() throws {
        let result = sem_wait(self.semaphoreID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

    /// Test if resources are available
    ///
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    ///
    /// - returns: false if the semaphore resources are at zero already,
    ///            true if the semaphore could be aquired
    public func tryWait() throws -> Bool {
        let result = sem_trywait(self.semaphoreID)
        if result != 0 {
            let err = SysError(errno: result)
            if case .TryAgain = err {
                return false
            }
            throw err
        }
        return true
    }

    /// Release a resource to the semaphore
    public func post() {
        sem_post(self.semaphoreID)
    }

    /// Execute a block aquiring resources from the semaphore and return the
    /// resources afterwards, this is the prefered function to call.
    ///
    /// - parameter cb: block to execute
    public func whileLocking(cb: (Void) -> Void) throws {
        try self.wait()
        cb()
        self.post()
    }
}
