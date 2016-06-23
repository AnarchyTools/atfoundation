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

#if false
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Dispatch

public typealias ReceiveCallback = ((socket: ConnectedSocket, char: UInt8) -> Bool)
public typealias CloseCallback = ((socket: ConnectedSocket) -> Void)
public typealias SendCallback = ((socket: ConnectedSocket, stream: protocol<InputStream, SeekableStream>) -> Void)  

/// Sockets
public class Socket {
    /// Create a listening socket
    ///
    /// - parameter address: IP address to listen on of ``.Wildcard``
    /// - parameter port: port number to listen on
    /// - receiveCallback: callback to call when data is received, use the ``socket`` parameter to distinguish between multiple connections
    /// - returns: listening socket, discard all references to close the socket
    public class func listen(address: IPAddress, port: UInt16, receiveCallback: ReceiveCallback) -> ListeningSocket? {
        return ListeningSocket(address: address, port: port, receiveCallback: receiveCallback)
    }

    /// Connect to an IP address
    ///
    /// - parameter address: IP address to connect to
    /// - parameter port: port number to connect to
    /// - parameter receiveCallback: callback to call when data arrives
    /// - returns: connected socket, call ``send`` on that to send data, discard all references to close the socket
    public class func connect(address: IPAddress, port: UInt16, receiveCallback: ReceiveCallback) -> ConnectedSocket? {
        return ConnectedSocket(address: address.description, port: port, receiveCallback: receiveCallback)
    }

    /// Connect to a domain
    ///
    /// - parameter domain: domain to connect to
    /// - parameter port: port number to connect to
    /// - parameter receiveCallback: callback to call when data arrives
    /// - returns: connected socket, call ``send`` on that to send data, discard all references to close the socket
    public class func connect(domain: String, port: UInt16, receiveCallback: ReceiveCallback) -> ConnectedSocket? {
        return ConnectedSocket(address: domain, port: port, receiveCallback: receiveCallback)
    }
}

private func handleConnection(fd: Int32, remote: IPAddress, queue: dispatch_queue_t, receiveCallback: ReceiveCallback, closeCallback: CloseCallback? = nil) -> ConnectedSocket? {
    guard let readSrc = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(fd), 0, queue) else {
        return nil
    }
    let desc = ConnectedSocket(read: readSrc, remote: remote, fd: fd, queue: queue)

    dispatch_source_set_event_handler(readSrc) { [weak desc] in
        if let desc = desc {
            var c: UInt8 = 0

            // read a byte
            if read(desc.fd, &c, 1) != 1 {
                if errno == EAGAIN || errno == EINTR {
                    // if we got interrupted just try again
                    return
                }
            }
        
            if !receiveCallback(socket: desc, char: c) {
                // if callback returns false, do not read more data
                dispatch_source_cancel(readSrc)
            }
        } else {
            dispatch_source_cancel(readSrc)
        }
    }
    
    dispatch_source_set_cancel_handler(readSrc) { [weak desc] in
        // if no one uses the socket anymore close it and remove the open connection from the list
        // close(desc.fd)
        if let closeCallback = closeCallback, desc = desc {
            closeCallback(socket: desc)
        }
    }   
    dispatch_resume(readSrc)

    return desc
}

/// Listening socket, opaque item, keep reference to keep listening
public class ListeningSocket {
    var sock: Int32 = -1
    var workerQueue: dispatch_queue_t
    var workerSource: dispatch_source_t?
    
    var openConnections = [ConnectedSocket]()
    
    var receiveCallback: ReceiveCallback

    internal init?(address addr: IPAddress, port: UInt16, receiveCallback:ReceiveCallback) {
        // setup worker queue
        self.workerQueue = dispatch_queue_create("org.anarchytools.socketlistener", DISPATCH_QUEUE_CONCURRENT)
        
        // setup ip address query
        var hints = addrinfo()
        var address: String? = nil
        switch addr {
        case .IPv4:
            hints.ai_family = AF_INET
            address = addr.description
        case .IPv6:
            hints.ai_family = AF_INET6
            address = addr.description
        case .Wildcard:
            hints.ai_family = AF_UNSPEC
            hints.ai_flags = AI_PASSIVE
        }
        hints.ai_socktype = Int32(SOCK_STREAM)
        
        // execute query
        var tmpAddrInfo = UnsafeMutablePointer<addrinfo>(nil)
        var result: Int32
        if address == nil {
            result = getaddrinfo(nil, "\(port)", &hints, &tmpAddrInfo)
        } else {
            result = getaddrinfo(address!, "\(port)", &hints, &tmpAddrInfo)
        }
        guard let addrInfo = tmpAddrInfo where result == 0 else {
            Log.error("Socket listen(): getaddrinfo error: \(gai_strerror(result))")
            return nil
        }
        
        var info = addrInfo.pointee
        while true {
            if info.ai_next == nil || info.ai_family == AF_INET6 {
                break
            }
            info = info.ai_next.pointee
        }
        
        // create socket
        self.sock = socket(info.ai_family, info.ai_socktype, info.ai_protocol)
        if self.sock < 0 {
            Log.error("Socket listen(): socket creation failed: \(strerror(errno))")
            return nil
        }
        
        // allow reuse
        var yes:Int32 = 1
        setsockopt(self.sock, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(sizeof(Int32)))
        
        // bind to port
        result = bind(self.sock, info.ai_addr, info.ai_addrlen)
        if result < 0 {
            Log.error("Socket listen(): bind failed: \(strerror(errno))")
        }
        
        // free query result
        freeaddrinfo(addrInfo)
        
        // start listening
        result = listen(self.sock, 20)
        if result < 0 {
            Log.error("Socket listen(): listening failed: \(strerror(errno))")
            close(self.sock)
            return nil
        }
        
        self.receiveCallback = receiveCallback
        
        // dispatch accept calls
        self.workerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(self.sock), 0, self.workerQueue)
        dispatch_source_set_event_handler(self.workerSource!) { [unowned self] in
            var remoteAddr = sockaddr_storage()
            var len = socklen_t(sizeof(sockaddr_storage))
            let sockFD = withUnsafeMutablePointer(&remoteAddr) { remoteAddrPtr in
                return accept(self.sock, UnsafeMutablePointer(remoteAddrPtr), &len)
            }
            if sockFD >= 0 {
                // yay we have a socket, create dispatch source for reading
                guard let ip = IPAddress(fromString: remoteAddr.description) else {
                    // ok something went wrong
                    close(sockFD)
                    return
                }
                if let desc = handleConnection(
                        fd: sockFD,
                        remote: ip,
                        queue: self.workerQueue,
                        receiveCallback: self.receiveCallback,
                        closeCallback: { (socket: ConnectedSocket) in
                            self.openConnections.remove(at: self.openConnections.index(where: { cDesc -> Bool in
                                return cDesc.fd == socket.fd
                            })!)
                        }
                    ) {
                    self.openConnections.append(desc)
                }
            }
        }
        dispatch_resume(self.workerSource!)
    }

    deinit {
        if let workerSource = self.workerSource {
            dispatch_source_cancel(workerSource)
        }
        self.openConnections.removeAll()
        close(self.sock)
    }
}

/// Connected socket, use to send data
public class ConnectedSocket {
    struct QueuedData {
        let stream: protocol<InputStream, SeekableStream>
        let callback: SendCallback?
    }

    /// File descriptor of socket, usable as temporary ID, used to call ``ioctl``
    public let fd: Int32
    var workerQueue: dispatch_queue_t
    var readSource: dispatch_source_t?
    var writeSource: dispatch_source_t?
    var remote: IPAddress?
    var sendQueue = [QueuedData]()

    var receiveCallback: ReceiveCallback?

    /// Initializer that is called if the socket is outgoing
    internal init?(address addr: String, port: UInt16, receiveCallback: ReceiveCallback) {
        // setup worker queue
        self.workerQueue = dispatch_queue_create("org.anarchytools.socket", DISPATCH_QUEUE_CONCURRENT)

        self.receiveCallback = receiveCallback

        // setup query
        var hints = addrinfo()
        hints.ai_family = AF_UNSPEC
        hints.ai_socktype = SOCK_STREAM
        
        // execute query
        var tmpAddrInfo = UnsafeMutablePointer<addrinfo>(nil)
        let result = getaddrinfo(addr, "\(port)", &hints, &tmpAddrInfo)
        
        guard let addrInfo = tmpAddrInfo where result == 0 else {
            Log.error("Socket connect(): getaddrinfo error: \(gai_strerror(result))")
            return nil
        }
        
        // create socket
        let fd = socket(addrInfo.pointee.ai_family, addrInfo.pointee.ai_socktype, addrInfo.pointee.ai_protocol)
        self.fd = fd
        if self.fd < 0 {
            Log.error("Socket connect(): socket creation failed: \(strerror(errno))")
            return nil
        }

        // finally connect
        if connect(self.fd, addrInfo.pointee.ai_addr, addrInfo.pointee.ai_addrlen) < 0 {
            Log.error("Socket connect(): connection failed: \(strerror(errno))")
            return nil
        }
        
        var remoteAddr = sockaddr_storage()
        var len = socklen_t(sizeof(sockaddr_storage))
        withUnsafeMutablePointer(&remoteAddr) { remoteAddrPtr in
            getpeername(fd, UnsafeMutablePointer(remoteAddrPtr), &len)
        }
        guard let ip = IPAddress(fromString: remoteAddr.description) else {
            return nil
        }

        handleConnection(
            fd: self.fd,
            remote: ip,
            queue: self.workerQueue,
            receiveCallback: self.receiveCallback!,
            closeCallback: nil)
        
        // free query result
        freeaddrinfo(addrInfo)
    }

    /// Initializer for incoming socket
    internal init(read: dispatch_source_t, remote: IPAddress, fd: Int32, queue: dispatch_queue_t) {
        self.workerQueue = queue
        self.readSource = read
        self.remote = remote
        self.fd = fd
    }

    /// Send bytes
    ///
    /// - parameter data: Array of bytes to send
    /// - parameter successCallback: callback to call when sending of this data block has been finished
    public func send(data: [UInt8], successCallback: SendCallback?) -> Bool {
        let stream = MemoryStream(data: data)
        stream.position = 0
        return self.send(stream: stream, successCallback: successCallback)
    }

    /// Send string (UTF8)
    ///
    /// - parameter string: String to send
    /// - parameter successCallback: callback to call when sending of this data block has been finished
    public func send(string: String, successCallback: SendCallback?) -> Bool {
        let stream = MemoryStream(string: string)
        stream.position = 0
        return self.send(stream: stream, successCallback: successCallback)
    }

    /// Send bytes from a stream
    ///
    /// - parameter stream: Stream to read data from, will begin sending data from current positon
    /// - parameter successCallback: callback to call when sending of this data block has been finished
    public func send(stream: protocol<InputStream, SeekableStream>, successCallback:SendCallback?) -> Bool {
        self.sendQueue.append(QueuedData(stream: stream, callback: successCallback))

        if self.writeSource == nil {
            // start write source
            guard let writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, UInt(self.fd), 0, self.workerQueue) else {
                return false
            }
            self.writeSource = writeSource
            dispatch_source_set_event_handler(writeSource) { [unowned self] in
                
                if let queueItem = self.sendQueue.first {
                    let estimated = dispatch_source_get_data(writeSource)
                    do {
                        var dataToSend: [UInt8] = try queueItem.stream.read(size: Int(estimated))
                
                        Log.debug("data", dataToSend)
                        while true {
                            if write(self.fd, &dataToSend, dataToSend.count) != dataToSend.count {
                                if errno == EAGAIN || errno == EINTR {
                                    // if we got interrupted just try again
                                    continue
                                }
                                break
                            }
                            break
                        }
                    } catch {
                        Log.error("Could not read data to send")
                    }
                    
                    // when finished, call success callback and pop the data item from the queue
                    if queueItem.stream.position == queueItem.stream.size {
                        if let callback = queueItem.callback {
                            callback(socket: self, stream: queueItem.stream)
                        }
                        self.sendQueue.removeFirst()
                    }
                }
                
                // cancel the write source when there are not items in the send queue anymore
                if self.sendQueue.count == 0 {
                    dispatch_source_cancel(writeSource)
                    self.writeSource = nil
                }
            }

            dispatch_resume(writeSource)
        }
        
        return true
    }

    deinit {
        if let readSource = self.readSource {
            dispatch_source_cancel(readSource)
        }
        if let writeSource = self.writeSource {
            dispatch_source_cancel(writeSource)
        }
        close(self.fd)
    }
}
#endif
