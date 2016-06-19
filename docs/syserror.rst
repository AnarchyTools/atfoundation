===============================
POSIX System errors (``errno``)
===============================


.. swift:enum:: SysError : ErrorProtocol

   .. swift:enum_case:: OperationNotPermitted


   .. swift:enum_case:: NoSuchEntity(Path?)


   .. swift:enum_case:: NoSuchProcess


   .. swift:enum_case:: Interrupted


   .. swift:enum_case:: IOError


   .. swift:enum_case:: NoSuchDeviceOrAddress


   .. swift:enum_case:: ArgumentListTooLong


   .. swift:enum_case:: ExecFormatError


   .. swift:enum_case:: BadFileDescriptor


   .. swift:enum_case:: NoChildProcess


   .. swift:enum_case:: TryAgain


   .. swift:enum_case:: OutOfMemory


   .. swift:enum_case:: AccessDenied(Path?)


   .. swift:enum_case:: BadAddress


   .. swift:enum_case:: BlockDeviceRequired(Path?)


   .. swift:enum_case:: DeviceOrResourceBusy


   .. swift:enum_case:: FileExists(Path?)


   .. swift:enum_case:: CrossDeviceLink(dest: Path?, src: Path?)


   .. swift:enum_case:: NoSuchDevice(Path?)


   .. swift:enum_case:: NotADirectory(Path?)


   .. swift:enum_case:: IsDirectory(Path?)


   .. swift:enum_case:: InvalidArgument(file: String, line: Int, function: String)


   .. swift:enum_case:: SystemFileDescriptorsExhausted


   .. swift:enum_case:: FileDescriptorsExhausted


   .. swift:enum_case:: NotATTY


   .. swift:enum_case:: TextFileBusy


   .. swift:enum_case:: FileTooLarge


   .. swift:enum_case:: NoSpaceLeftOnDevice


   .. swift:enum_case:: IllegalSeek


   .. swift:enum_case:: ReadOnlyFilesystem


   .. swift:enum_case:: TooManyLinks


   .. swift:enum_case:: BrokenPipe


   .. swift:enum_case:: MathArgumentOutOfDomainOfFunction


   .. swift:enum_case:: MathResultOutOfRange


   .. swift:enum_case:: Deadlock


   .. swift:enum_case:: NameTooLong(Path?)


   .. swift:enum_case:: NoLockAvailable


   .. swift:enum_case:: InvalidSystemCall(file: String, line: Int, function: String)


   .. swift:enum_case:: DirectoryNotEmpty(Path?)


   .. swift:enum_case:: SymlinkLoop


   .. swift:enum_case:: AddressInUse


   .. swift:enum_case:: AddressNotAvailable


   .. swift:enum_case:: NetworkDown


   .. swift:enum_case:: NetworkUnreachable


   .. swift:enum_case:: NetworkReset


   .. swift:enum_case:: ConnectionAborted


   .. swift:enum_case:: ConnectionResetByPeer


   .. swift:enum_case:: BufferSpaceExhausted


   .. swift:enum_case:: AlreadyConnected


   .. swift:enum_case:: NotConnected


   .. swift:enum_case:: AlreadyShutDown


   .. swift:enum_case:: ConnectionTimedOut


   .. swift:enum_case:: ConnectionRefused


   .. swift:enum_case:: HostIsDown


   .. swift:enum_case:: NoRouteToHost


   .. swift:enum_case:: QuotaExceeded


   .. swift:enum_case:: EndOfFile


   .. swift:enum_case:: UnknownError(file: String, line: Int, function: String)


   .. swift:init:: init(errno: Int32, _ info: Any..., file: String = #file, line: Int = #line, function: String = #function)



