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

/// A runloop
public class Runloop {
	static var mainLoop = Runloop(name: "main")

	/// name of this runloop
	private(set) public var name: String

	/// running state of this runloop
	private(set) public var running: Bool = false

	/// suspend state of this runloop
	public var paused: Bool = false

	/// cancel state of the runloop
	private var canceled: Bool = false

	/// barrier for idle state
	private let barrier = Barrier()

	/// block queue for blocks to execute next
	private var blockQueue = [(Void) -> Void]()

	/// queue lock
	private let queueLock = Mutex()

	/// file descriptor queue
	private var watchQueue = [Stream]()

	/// file descriptor queue lock
	private let watchLock = Mutex()

	/// Initialize new runloop
	///
	/// - parameter name: Name of the runloop
	public init(name: String) {
		self.name = name
	}

	/// Start the runloop, will not return until canceled
	public func run() {
		if self.running {
			return
		}

		self.canceled = false
		self.running = true

		// spawn fd watcher thread
		let _ = Thread() { (Void) -> Void in
			self.watchThread()
		}

		while !canceled {

			// fetch an item from the block queue
			var block: ((Void) -> Void)? = nil
			try! self.queueLock.whileLocking {
				if self.blockQueue.count > 0 {
					block = self.blockQueue.removeFirst()
				}
			}

			// if we got an item run the callback
			if let block = block {
				block()

				// instantly try again
				continue
			}

			// if we get here the block queue was empty
			// block at the barrier
			self.barrier.wait()
		}
		self.running = false
	}

	/// Start the runloop in a detached thread
	public func runDetached() {
		if self.running {
			return
		}
		let _ = Thread() { (Void) -> Void in
			self.run()
		}
	}

	/// cancel the runloop
	public func cancel() {
		self.canceled = true
	}

	/// Enqueue block for running in this runloop
	///
	/// - parameter priority: optional, set to ``true`` if you want this
	///                       block to be executed before everything that
	///                       is already queued
	/// - parameter block: the block to execute
	public func queueBlock(priority: Bool = false, _ block: @escaping (Void) -> Void) {
		try! self.queueLock.whileLocking {
			if priority {
				self.blockQueue.insert(block, at:0)
			} else {
				self.blockQueue.append(block)
			}
		}
		self.barrier.signal()
	}

	/// Add an InputStream to the watch list
	///
	/// - parameter stream: Stream to watch for readable file descriptor
	/// - parameter callback: the callback to queue in this runloop when the
	///                       file descriptor becomes readable
	public func watchForRead(stream: InputStream, callback: @escaping (InputStream) -> Void) {
		try! self.watchLock.whileLocking {
			self.watchQueue.append(stream)
		}		
	}

	/// Add an OutputStream to the watch list
	///
	/// - parameter stream: Stream to watch for writable file descriptor
	/// - parameter callback: the callback to queue in this runloop when the
	///                       file descriptor becomes writable
	public func watchForWrite(stream: OutputStream, callback: @escaping (OutputStream) -> Void) {
		try! self.watchLock.whileLocking {
			self.watchQueue.append(stream)
		}		
	}

	/// thread main for file descriptor watcher, emits blocks to the runloop
	/// if something happens
	private func watchThread() {
		while !self.canceled {
			sleep(1)
		}
	}
}