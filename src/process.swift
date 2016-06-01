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

/// Subprocess runner
public class SubProcess {

	/// Definition which environment variables should be copied by default to
	/// the environment of child processes.
	public static var defaultEnvironmentVariables = [
		// minimum default
		"HOME", "PATH", "MANPATH", "TMPDIR",

		// shell editors
		"PAGER", "EDITOR", "VISUAL", "DISPLAY",

		// proxies
		"ftp_proxy", "http_proxy",

		// terminal type
		"TERM",

		// locale config
		"TZ", "LANG", "LANGUAGE",
		"LC_CTYPE", "LC_NUMERIC", "LC_TIME", "LC_COLLATE", "LC_MONETARY", "LC_MESSAGES",
		"LC_PAPER", "LC_NAME", "LC_ADDRESS", "LC_TELEPHONE", "LC_MEASUREMENT", "LC_IDENTIFICATION", "LC_ALL",

		// compiler stuff
		"CC", "CXX", "CPP", "LD_LIBRARY_PATH", "DYLD_LIBRARY_PATH", "LIBRARY_PATH",

		// ssh session stuff
		"SSH_CLIENT", "SSH_TTY", "SSH_CONNECTION"
	]

	/// Executable path
	public var executable: Path

	/// Command line arguments to the program
	public var arguments: [String]

	/// Environment setup for the program, if not defined at init
	/// time it defaults to a copy of values from the local environment
	public var environment = [String:String]()

	/// Working directory to start the program in, defaults to current dir
	public var workingDirectory = Path(".")

	/// If the process is running stores the pid
	private(set) public var pid: pid_t? = nil

	/// Initialize a new sub process
	///
	/// - parameter executable: the executable to run, if you just supply
	///                         a name the `PATH` is searched for it
	/// - parameter environment: the environment to setup for the child
	///                          process, if not set it defaults to
	///                          `SubProcess.defaultEnvironment`
	/// - parameter arguments: list of command line arguments to use
	public init(executable: Path, environment: [String:String]? = nil, arguments: String...) {
		self.executable = executable
		self.arguments = arguments
		if let e = environment {
			self.environment = e
		} else {
			self.environment = SubProcess.defaultEnvironment
		}
	}

	/// Run the sub process, blocking until finished, returning the exit value
	///
	/// - parameter stdin: optional, stream to use for stdin
	/// - returns: exit code of command
	public func run(stdin: InputStream? = nil) throws -> Int32 {
		try self.spawn(stdin: stdin)
		return self.waitForExit()
	}

	/// Run the sub process asynchronously, returning a stream for stdout
	///
	/// - parameter stdin: optional, stream to use for stdin
	/// - returns: readable stream for stdout
	public func run(stdin: InputStream? = nil) throws -> InputStream {
		let stream = try UnidirectionalPipe()
		try self.spawn(stdin: stdin, stdout: stream.write)
		return stream.read
	}

	/// Run the sub process asynchronously, returning a bidirectional stream for stdin/out
	///
	/// - returns: bi-directional stream for stdin/stdout
	public func run() throws -> protocol<InputStream, OutputStream> {
		let stream = try BidirectionalPipe()
		try self.spawn(stdin: stream.0, stdout: stream.0)
		return stream.1
	}

	/// Run the sub process, blocking until finished, returning stdout as string array
	///
	/// - parameter stdin: optional, stream to use for stdin
	/// - returns: exit code and array of strings (lines of output) for command output
	public func run(stdin: InputStream? = nil) throws -> (exitCode: Int32, output: [String]) {
		var output = [String]()
		let stream = try UnidirectionalPipe()
		try self.spawn(stdin: stdin, stdout: stream.write)
		while true {
			do {
				if let line = try stream.read.readLine() {
					output.append(line)
				}
			} catch SysError.EndOfFile {
				break;
			} catch {
				throw error
			}
		}
		return (exitCode: self.waitForExit(), output: output)
	}

	/// Run the sub process asynchronously, returning streams for stdout and stderr
	///
	/// - parameter stdin: optional, stream to use for stdin
	/// - returns: readable stream for stdout
	public func run(stdin: InputStream? = nil) throws -> (stdout: InputStream, stderr: InputStream) {
		let out = try UnidirectionalPipe()
		let err = try UnidirectionalPipe()
		try self.spawn(stdin: stdin, stdout: out.write, stderr: err.write)
		return (stdout: out.read, stderr: err.read)
	}

	/// Wait for a sub process to exit
	///
	/// - returns: exit code
	public func waitForExit() -> Int32 {
		if let pid = self.pid {
			var returnValue: Int32 = 0
			waitpid(pid, &returnValue, 0)
			return returnValue >> 8
		}
		return -1
	}

	/// Prepare data for posix_spawn and run the process
	///
	/// - parameter stdin: optional stream to connect to processes stdin
	/// - parameter stdout: optional stream to connect to processes stdout
	/// - parameter stderr: optional stream to connect to processes stderr
	private func spawn(stdin: InputStream? = nil, stdout: OutputStream? = nil, stderr: OutputStream? = nil) throws {
		var pid = pid_t()

		// arguments
		var args = self.arguments
		args.insert(self.executable.description, at: 0)

		let argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?> = args.withUnsafeBufferPointer { ptr in
            let array : UnsafeBufferPointer<String> = ptr
            let buffer = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>(allocatingCapacity: array.count + 1)
            buffer.initializeFrom(array.map { $0.withCString(strdup) })
            buffer[array.count] = nil
            return buffer
        }

        defer {
            for arg in argv ..< argv + args.count {
                free(UnsafeMutablePointer<Void>(arg.pointee))
            }
            argv.deallocateCapacity(args.count + 1)
        }

        // environment
        let env: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>
        env = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>(allocatingCapacity: 1 + self.environment.count)
        env.initializeFrom(self.environment.map { strdup("\($0)=\($1)") })
        env[self.environment.count] = nil

        defer {
            for pair in env ..< env + self.environment.count {
                free(UnsafeMutablePointer<Void>(pair.pointee))
            }
            env.deallocateCapacity(self.environment.count + 1)
        }

		// file descriptors
#if os(Linux)
		var actions = posix_spawn_file_actions_t()
#else
		var actions = posix_spawn_file_actions_t(nil)
#endif
		posix_spawn_file_actions_init(&actions)
		defer { posix_spawn_file_actions_destroy(&actions) }

		// FIXME: Some streams do not have an fd (MemoryStream comes to mind).
		if let stdin = stdin {
			posix_spawn_file_actions_adddup2(&actions, stdin.fd, 0)
		}
		if let stdout = stdout {
			posix_spawn_file_actions_adddup2(&actions, stdout.fd, 1)
		}
		if let stderr = stderr {
			posix_spawn_file_actions_adddup2(&actions, stderr.fd, 2)
		}

		// settings
#if os(Linux)
		var attributes = posix_spawnattr_t()
#else
		var attributes = posix_spawnattr_t(nil)
#endif
		posix_spawnattr_init(&attributes)
		defer { posix_spawnattr_destroy(&attributes) }
#if os(OSX)
		posix_spawnattr_setflags(&attributes, Int16(POSIX_SPAWN_CLOEXEC_DEFAULT))
#endif

		if self.workingDirectory.description != "." {
			let oldWorkdir = try FS.getWorkingDirectory()
			try FS.changeWorkingDirectory(path: self.workingDirectory)
			defer { do { try FS.changeWorkingDirectory(path: oldWorkdir) } catch {} }
		}
		let result = posix_spawnp(&pid, self.executable.description, &actions, &attributes, argv, env);
		if result != 0 {
			throw SysError(errno: result)
		}

		if stdin != nil {
			stdin!.closeStream()
		}
		if stdout != nil {
			stdout!.closeStream()
		}
		if stderr != nil {
			stderr!.closeStream()
		}

		self.pid = pid
	}

	/// Create a copy of the environment only containing variables defined as default
	public static var defaultEnvironment: [String:String] {
		var environment = [String:String]()
		for variable in SubProcess.defaultEnvironmentVariables {
			let value = getenv(variable)
			if value != nil {
				environment[variable] = String(validatingUTF8: value!)
			}
		}
		return environment
	}

	/// Shell escape a argument, not needed if the API takes argument lists
	///
	/// - parameter argument: the argument to escape
	/// - returns: escaped (safe) argument
	public class func shellEscape(argument: String) -> String {
		if argument == "" {
			return "''"
		}
		return "'" + argument.replacing(searchTerm: "'", replacement: "'\"'\"'") + "'"
	}
}
