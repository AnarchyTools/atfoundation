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

public class SubProcess {
	public var executable: Path
	public var arguments: [String]
	public var environment: [String]
	public var workingDirectory = Path(".")

	public init(executable: Path, arguments: String...) {
		self.executable = executable
		self.arguments = arguments
		self.environment = Process.environment
	}

	public func run(stdin: InputStream? = nil) throws -> Int32 {
		var cmd = self.arguments
		cmd.insert(self.executable.description, at: 0)
		let command = String.join(parts: cmd.map({ SubProcess.shellEscape(argument: $0) }), delimiter: " ")
		return system(command)
	}

	public func run(stdin: InputStream? = nil) throws -> InputStream? {
		return nil
	}

	public func run(stdin: InputStream? = nil) throws -> [String] {
		return []
	}

	public func run(stdin: InputStream? = nil) throws -> (stdout: InputStream?, stderr: InputStream?) {
		return (stdout: nil, stderr: nil)
	}


	private func spawn(actions: posix_spawn_file_actions_t, attr: posix_spawnattr_t) -> pid_t {
		var pid = pid_t()
		var argv = self.arguments
		argv.insert(self.executable.description, at: 0)

		// let result = posix_spawnp(&pid, self.executable.description, &actions, &attr, argv, self.environment);
		// if result != 0 {
		// 	throw SysError(result)
		// }
		return pid
	}

	public class func shellEscape(argument: String) -> String {
		if argument == "" {
			return "''"
		}
		return "'" + argument.replacing(searchTerm: "'", replacement: "'\"'\"'") + "'"
	}
}