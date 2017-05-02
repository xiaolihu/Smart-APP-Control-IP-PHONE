//
//  TCPClient.swift
//  ControlIPPhoneViaBLE

//  This product includes software developed by skysent.
//

import Foundation


@_silgen_name("ytcpsocket_connect") private func c_ytcpsocket_connect(_ host:UnsafePointer<Byte>,port:Int32,timeout:Int32) -> Int32
@_silgen_name("ytcpsocket_close") private func c_ytcpsocket_close(_ fd:Int32) -> Int32
@_silgen_name("ytcpsocket_send") private func c_ytcpsocket_send(_ fd:Int32,buff:UnsafePointer<Byte>,len:Int32) -> Int32
@_silgen_name("ytcpsocket_pull") private func c_ytcpsocket_pull(_ fd:Int32,buff:UnsafePointer<Byte>,len:Int32,timeout:Int32) -> Int32

@_silgen_name("ytcpsocket_port") private func c_ytcpsocket_port(_ fd:Int32) -> Int32

open class TCPClient: Socket {
    
    /*
     * connect to server
     * return success or fail with message
     */
    open func connect(timeout: Int) -> Result {
        let rs: Int32 = c_ytcpsocket_connect(self.address, port: Int32(self.port), timeout: Int32(timeout))
        if rs > 0 {
            self.fd = rs
            return .success
        } else {
            switch rs {
            case -1:
                return .failure(SocketError.queryFailed)
            case -2:
                return .failure(SocketError.connectionClosed)
            case -3:
                return .failure(SocketError.connectionTimeout)
            default:
                return .failure(SocketError.unknownError)
            }
        }
    }
    
    /*
     * close socket
     * return success or fail with message
     */
    open func close() {
        guard let fd = self.fd else { return }
        
        _ = c_ytcpsocket_close(fd)
        self.fd = nil
    }
    
    /*
     * send data
     * return success or fail with message
     */
    open func send(data: [Byte]) -> Result {
        guard let fd = self.fd else { return .failure(SocketError.connectionClosed) }
        
        let sendsize: Int32 = c_ytcpsocket_send(fd, buff: data, len: Int32(data.count))
        if Int(sendsize) == data.count {
            return .success
        } else {
            return .failure(SocketError.unknownError)
        }
    }
    
    /*
     * send string
     * return success or fail with message
     */
    open func send(string: String) -> Result {
        guard let fd = self.fd else { return .failure(SocketError.connectionClosed) }
        
        let sendsize = c_ytcpsocket_send(fd, buff: string, len: Int32(strlen(string)))
        if sendsize == Int32(strlen(string)) {
            return .success
        } else {
            return .failure(SocketError.unknownError)
        }
    }
    
    /*
     *
     * send nsdata
     */
    open func send(data: Data) -> Result {
        guard let fd = self.fd else { return .failure(SocketError.connectionClosed) }
        
        var buff = [Byte](repeating: 0x0,count: data.count)
        (data as NSData).getBytes(&buff, length: data.count)
        let sendsize = c_ytcpsocket_send(fd, buff: buff, len: Int32(data.count))
        if sendsize == Int32(data.count) {
            return .success
        } else {
            return .failure(SocketError.unknownError)
        }
    }
    
    /*
     * read data with expect length
     * return success or fail with message
     */
    open func read(_ expectlen:Int, timeout:Int = -1) -> [Byte]? {
        guard let fd:Int32 = self.fd else { return nil }
        
        var buff = [Byte](repeating: 0x0,count: expectlen)
        let readLen = c_ytcpsocket_pull(fd, buff: &buff, len: Int32(expectlen), timeout: Int32(timeout))
        if readLen <= 0 { return nil }
        let rs = buff[0...Int(readLen-1)]
        let data: [Byte] = Array(rs)
        
        return data
    }
}
