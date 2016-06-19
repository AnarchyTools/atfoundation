=============
Sub-Processes
=============


.. swift:class:: SubProcess

   .. swift:static_var:: defaultEnvironmentVariables= [

    Definition which environment variables should be copied by default to
    the environment of child processes.

   .. swift:var:: executable: Path

    Executable path

   .. swift:var:: arguments: [String]

    Command line arguments to the program

   .. swift:var:: environment= [String:String]()

    Environment setup for the program, if not defined at init
    time it defaults to a copy of values from the local environment

   .. swift:var:: workingDirectory= Path(".")

    Working directory to start the program in, defaults to current dir

   .. swift:var:: pid: pid_t? = nil

    If the process is running stores the pid

   .. swift:init:: init(executable: Path, environment: [String:String]? = nil, arguments: String...)

     Initialize a new sub process

     :parameter executable: the executable to run, if you just supply a name the ``PATH`` is searched for it
     :parameter environment: the environment to setup for the child process, if not set it defaults to ``SubProcess.defaultEnvironment``
     :parameter arguments: list of command line arguments to use

   .. swift:method:: run(stdin: InputStream? = nil) throws -> Int32

    Run the sub process, blocking until finished, returning the exit value

    :parameter stdin: optional, stream to use for stdin
    :returns: exit code of command

   .. swift:method:: run(stdin: InputStream? = nil) throws -> InputStream

    Run the sub process asynchronously, returning a stream for stdout

    :parameter stdin: optional, stream to use for stdin
    :returns: readable stream for stdout

   .. swift:method:: run() throws -> protocol<InputStream, OutputStream>

    Run the sub process asynchronously, returning a bidirectional stream for stdin/out

    :returns: bi-directional stream for stdin/stdout

   .. swift:method:: run(stdin: InputStream? = nil) throws -> (exitCode: Int32, output: [String])

    Run the sub process, blocking until finished, returning stdout as string array

    :parameter stdin: optional, stream to use for stdin
    :returns: exit code and array of strings (lines of output) for command output

   .. swift:method:: run(stdin: InputStream? = nil) throws -> (stdout: InputStream, stderr: InputStream)

    Run the sub process asynchronously, returning streams for stdout and stderr

    :parameter stdin: optional, stream to use for stdin
    :returns: readable stream for stdout

   .. swift:method:: waitForExit() -> Int32

    Wait for a sub process to exit

    :returns: exit code

   .. swift:static_var:: defaultEnvironment: [String:String]

    Create a copy of the environment only containing variables defined as default

   .. swift:class_method:: shellEscape(argument: String) -> String

    Shell escape a argument, not needed if the API takes argument lists

    :parameter argument: the argument to escape
    :returns: escaped (safe) argument


