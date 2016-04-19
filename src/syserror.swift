public enum SysError: Int32, ErrorProtocol {
#if os(Linux)
    // Generic
    case OperationNotPermitted = 1
    case NoSuchEntity = 2
    case NoSuchProcess = 3
    case Interrupted = 4
    case IOError = 5
    case NoSuchDeviceOrAddress = 6
    case ArgumentListTooLong = 7
    case ExecFormatError = 8
    case BadFileDescriptor = 9
    case NoChildProcess = 10
    case TryAgain = 11
    case OutOfMemory = 12
    case AccessDenied = 13
    case BadAddress = 14
    case BlockDeviceRequired = 15
    case DeviceOrResourceBusy = 16
    case FileExists = 17
    case CrossDeviceLink = 18
    case NoSuchDevice = 19
    case NotADirectory = 20
    case IsDirectory = 21
    case InvalidArgument = 22
    case SystemFileDescriptorsExhausted = 23
    case FileDescriptorsExhausted = 24
    case NotATTY = 25
    case TextFileBusy = 26
    case FileTooLarge = 27
    case NoSpaceLeftOnDevice = 28
    case IllegalSeek = 29
    case ReadOnlyFilesystem = 30
    case TooManyLinks = 31
    case BrokenPipe = 32
    case MathArgumentOutOfDomainOfFunction = 33
    case MathResultOutOfRange = 34
    case Deadlock = 35
    case NameTooLong = 36
    case NoLockAvailable = 37
    case InvalidSystemCall = 38
    // case DirectoryNotEmpty = 39
    case SymlinkLoop = 40

    // Network
    case AddressInUse = 98
    case AddressNotAvailable = 99
    case NetworkDown = 100
    case NetworkUnreachable = 101
    case NetworkReset = 102
    case ConnectionAborted = 103
    case ConnectionResetByPeer = 104
    case BufferSpaceExhausted = 105
    case AlreadyConnected = 106
    case NotConnected = 107
    case AlreadyShutDown = 108
    case ConnectionTimedOut = 110
    case ConnectionRefused = 111
    case HostIsDown = 112
    case NoRouteToHost = 113

    // Quota
    case QuotaExceeded = 122
#else
    // Generic
    case OperationNotPermitted = 1
    case NoSuchEntity = 2
    case NoSuchProcess = 3
    case Interrupted = 4
    case IOError = 5
    case NoSuchDeviceOrAddress = 6
    case ArgumentListTooLong = 7
    case ExecFormatError = 8
    case BadFileDescriptor = 9
    case NoChildProcess = 10
    case TryAgain = 35
    case OutOfMemory = 12
    case AccessDenied = 13
    case BadAddress = 14
    case BlockDeviceRequired = 15
    case DeviceOrResourceBusy = 16
    case FileExists = 17
    case CrossDeviceLink = 18
    case NoSuchDevice = 19
    case NotADirectory = 20
    case IsDirectory = 21
    case InvalidArgument = 22
    case SystemFileDescriptorsExhausted = 23
    case FileDescriptorsExhausted = 24
    case NotATTY = 25
    case TextFileBusy = 26
    case FileTooLarge = 27
    case NoSpaceLeftOnDevice = 28
    case IllegalSeek = 29
    case ReadOnlyFilesystem = 30
    case TooManyLinks = 31
    case BrokenPipe = 32
    case MathArgumentOutOfDomainOfFunction = 33
    case MathResultOutOfRange = 34
    case Deadlock = 11
    case NameTooLong = 63
    case NoLockAvailable = 77
    case InvalidSystemCall = 78
    // case DirectoryNotEmpty = ?
    case SymlinkLoop = 62

    // Network
    case AddressInUse = 48
    case AddressNotAvailable = 49
    case NetworkDown = 50
    case NetworkUnreachable = 51
    case NetworkReset = 52
    case ConnectionAborted = 53
    case ConnectionResetByPeer = 54
    case BufferSpaceExhausted = 55
    case AlreadyConnected = 56
    case NotConnected = 57
    case AlreadyShutDown = 58
    case ConnectionTimedOut = 60
    case ConnectionRefused = 61
    case HostIsDown = 64
    case NoRouteToHost = 65

    // Quota
    case QuotaExceeded = 69
#endif
    case EndOfFile = -1
    case UnknownError = -2
}

public func errnoToError(errno: Int32) -> SysError {
    guard let e = SysError(rawValue: errno) else {
        return SysError.UnknownError
    }
    return e
}
