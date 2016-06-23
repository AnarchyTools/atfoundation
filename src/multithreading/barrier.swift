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

/// Barrier primitive
final public class Barrier {
    private let mutex = Mutex()
    internal var conditionID = pthread_cond_t()

    /// Initialize a new barrier
    public init() {
        pthread_cond_init(&self.conditionID, nil)
    }

    deinit {
        pthread_cond_destroy(&self.conditionID)
    }

    /// Wait for a signal (stop at the barrier)
    ///
    /// - parameter timeout: optional, time in nano seconds to wait, set to nil or skip to wait forever
    public func wait(timeout: Int? = nil) {
        if let timeout = timeout {
            var ts = timespec()
            var tv = timeval()
            gettimeofday(&tv, nil)
            ts.tv_sec = tv.tv_sec + timeout / 1000000000
            ts.tv_nsec += timeout % 1000000000
            pthread_cond_timedwait(&self.conditionID, &self.mutex.mutexID, &ts)
        } else {
            pthread_cond_wait(&self.conditionID, &self.mutex.mutexID)
        }
    }

    /// Signal the barrier, all threads blocked on that barrier will resume execution
    public func signal() {
        pthread_cond_signal(&self.conditionID)
    }
}
