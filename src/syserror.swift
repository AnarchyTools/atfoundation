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

public enum SysError: Error {
    // Generic
    case OperationNotPermitted
    case NoSuchEntity(Path?)
    case NoSuchProcess // TODO: Parameters
    case Interrupted
    case IOError
    case NoSuchDeviceOrAddress
    case ArgumentListTooLong
    case ExecFormatError
    case BadFileDescriptor
    case NoChildProcess
    case TryAgain
    case OutOfMemory
    case AccessDenied(Path?)
    case BadAddress // TODO: Parameters
    case BlockDeviceRequired(Path?)
    case DeviceOrResourceBusy // TODO: Parameters
    case FileExists(Path?)
    case CrossDeviceLink(dest: Path?, src: Path?)
    case NoSuchDevice(Path?)
    case NotADirectory(Path?)
    case IsDirectory(Path?)
    case InvalidArgument
    case SystemFileDescriptorsExhausted
    case FileDescriptorsExhausted
    case NotATTY // TODO: Parameters
    case TextFileBusy // TODO: Parameters
    case FileTooLarge // TODO: Parameters
    case NoSpaceLeftOnDevice
    case IllegalSeek
    case ReadOnlyFilesystem
    case TooManyLinks
    case BrokenPipe
    case MathArgumentOutOfDomainOfFunction
    case MathResultOutOfRange
    case Deadlock
    case NameTooLong(Path?)
    case NoLockAvailable
    case InvalidSystemCall
    case DirectoryNotEmpty(Path?)
    case SymlinkLoop

    // Network
    case AddressInUse // TODO: Parameters
    case AddressNotAvailable // TODO: Parameters
    case NetworkDown
    case NetworkUnreachable
    case NetworkReset
    case ConnectionAborted
    case ConnectionResetByPeer
    case BufferSpaceExhausted
    case AlreadyConnected
    case NotConnected
    case AlreadyShutDown
    case ConnectionTimedOut
    case ConnectionRefused
    case HostIsDown // TODO: Parameters
    case NoRouteToHost // TODO: Parameters

    // Quota
    case QuotaExceeded

    // Not actually system errors
    case EndOfFile
    case UnknownError

    public init(errno: Int32, _ info: Any...) {
#if os(Linux)
        switch errno {
            case 1: self = .OperationNotPermitted
            case 2: self = .NoSuchEntity(info.first as? Path)
            case 3: self = .NoSuchProcess
            case 4: self = .Interrupted
            case 5: self = .IOError
            case 6: self = .NoSuchDeviceOrAddress
            case 7: self = .ArgumentListTooLong
            case 8: self = .ExecFormatError
            case 9: self = .BadFileDescriptor
            case 10: self = .NoChildProcess
            case 11: self = .TryAgain
            case 12: self = .OutOfMemory
            case 13: self = .AccessDenied(info.first as? Path)
            case 14: self = .BadAddress
            case 15: self = .BlockDeviceRequired(info.first as? Path)
            case 16: self = .DeviceOrResourceBusy
            case 17: self = .FileExists(info.first as? Path)
            case 18: self = .CrossDeviceLink(dest: info.first as? Path, src: info[1] as? Path)
            case 19: self = .NoSuchDevice(info.first as? Path)
            case 20: self = .NotADirectory(info.first as? Path)
            case 21: self = .IsDirectory(info.first as? Path)
            case 22: self = .InvalidArgument
            case 23: self = .SystemFileDescriptorsExhausted
            case 24: self = .FileDescriptorsExhausted
            case 25: self = .NotATTY
            case 26: self = .TextFileBusy
            case 27: self = .FileTooLarge
            case 28: self = .NoSpaceLeftOnDevice
            case 29: self = .IllegalSeek
            case 30: self = .ReadOnlyFilesystem
            case 31: self = .TooManyLinks
            case 32: self = .BrokenPipe
            case 33: self = .MathArgumentOutOfDomainOfFunction
            case 34: self = .MathResultOutOfRange
            case 35: self = .Deadlock
            case 36: self = .NameTooLong(info.first as? Path)
            case 37: self = .NoLockAvailable
            case 38: self = .InvalidSystemCall
            case 39: self = .DirectoryNotEmpty(info.first as? Path)
            case 40: self = .SymlinkLoop
            // Network
            case 98: self = .AddressInUse
            case 99: self = .AddressNotAvailable
            case 100: self = .NetworkDown
            case 101: self = .NetworkUnreachable
            case 102: self = .NetworkReset
            case 103: self = .ConnectionAborted
            case 104: self = .ConnectionResetByPeer
            case 105: self = .BufferSpaceExhausted
            case 106: self = .AlreadyConnected
            case 107: self = .NotConnected
            case 108: self = .AlreadyShutDown
            case 110: self = .ConnectionTimedOut
            case 111: self = .ConnectionRefused
            case 112: self = .HostIsDown
            case 113: self = .NoRouteToHost
            // Quota
            case 122: self = .QuotaExceeded
            // Default
            default: self = .UnknownError
        }
#else
        switch errno {
            // Generic
            case 1: self = .OperationNotPermitted
            case 2: self = .NoSuchEntity(info.first as? Path)
            case 3: self = .NoSuchProcess
            case 4: self = .Interrupted
            case 5: self = .IOError
            case 6: self = .NoSuchDeviceOrAddress
            case 7: self = .ArgumentListTooLong
            case 8: self = .ExecFormatError
            case 9: self = .BadFileDescriptor
            case 10: self = .NoChildProcess
            case 35: self = .TryAgain
            case 12: self = .OutOfMemory
            case 13: self = .AccessDenied(info.first as? Path)
            case 14: self = .BadAddress
            case 15: self = .BlockDeviceRequired(info.first as? Path)
            case 16: self = .DeviceOrResourceBusy
            case 17: self = .FileExists(info.first as? Path)
            case 18: self = .CrossDeviceLink(dest: info.first as? Path, src: info[1] as? Path)
            case 19: self = .NoSuchDevice(info.first as? Path)
            case 20: self = .NotADirectory(info.first as? Path)
            case 21: self = .IsDirectory(info.first as? Path)
            case 22: self = .InvalidArgument
            case 23: self = .SystemFileDescriptorsExhausted
            case 24: self = .FileDescriptorsExhausted
            case 25: self = .NotATTY
            case 26: self = .TextFileBusy
            case 27: self = .FileTooLarge
            case 28: self = .NoSpaceLeftOnDevice
            case 29: self = .IllegalSeek
            case 30: self = .ReadOnlyFilesystem
            case 31: self = .TooManyLinks
            case 32: self = .BrokenPipe
            case 33: self = .MathArgumentOutOfDomainOfFunction
            case 34: self = .MathResultOutOfRange
            case 11: self = .Deadlock
            case 63: self = .NameTooLong(info.first as? Path)
            case 77: self = .NoLockAvailable
            case 78: self = .InvalidSystemCall
            case 66: self = .DirectoryNotEmpty(info.first as? Path)
            case 62: self = .SymlinkLoop
            // Network
            case 48: self = .AddressInUse
            case 49: self = .AddressNotAvailable
            case 50: self = .NetworkDown
            case 51: self = .NetworkUnreachable
            case 52: self = .NetworkReset
            case 53: self = .ConnectionAborted
            case 54: self = .ConnectionResetByPeer
            case 55: self = .BufferSpaceExhausted
            case 56: self = .AlreadyConnected
            case 57: self = .NotConnected
            case 58: self = .AlreadyShutDown
            case 60: self = .ConnectionTimedOut
            case 61: self = .ConnectionRefused
            case 64: self = .HostIsDown
            case 65: self = .NoRouteToHost
            // Quota
            case 69: self = .QuotaExceeded
            // Default
            default: self = .UnknownError
        }
#endif
    }
}
