//
//  AppDelegate.swift
//  Echo Server Swift
//
//  Created by Jameson Ricks on 2/4/17.
//  Copyright © 2017 Jameson Ricks. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GCDAsyncSocketDelegate {

    // MARK: Constants
    
    let WELCOME_MSG = 0
    let ECHO_MSG = 1
    let WARNING_MSG = 2
    
    let READ_TIMEOUT = 15.0
    let READ_TIMEOUT_EXTENSION = 10.0
    
    
    
    // MARK: Class Variables
    
    let socketQueue = DispatchQueue(label: "socketQueue")
    
    var listenSocket = GCDAsyncSocket()
    var connectedSockets = NSMutableArray(capacity: 1)
    
    var viewController : NSViewController? = nil

    
    override init() {
        super.init()
        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
    }
    
    
    
    // MARK: AppDelegate Functions

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    
    
    // MARK: GCDAsyncSocketDelegate Functions
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        
        // This method is executed on the socketQueue (not the main thread)
        
        // add connection to array
        connectedSockets.add(newSocket)
        
        DispatchQueue.main.async {
            (self.viewController as! EchoServerViewController).logInfo(msg: "Accepted client \(newSocket.connectedHost!):\(newSocket.connectedPort)")
        }
        
        // Create a welcome message
        let welcomeMsg = "Welcome to the AsyncSocket Echo Server\r\n"
        let welcomeData = welcomeMsg.data(using: String.Encoding.utf8)
        
        // Write the message to the socket
        newSocket.write(welcomeData!, withTimeout: -1, tag: WELCOME_MSG)
        newSocket.readData(to: GCDAsyncSocket.crlfData(), withTimeout: READ_TIMEOUT, tag: 0)
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
        // This method is executed on the socketQueue (not the main thread)
        
        if tag == ECHO_MSG {
            sock.readData(to: GCDAsyncSocket.crlfData(), withTimeout: READ_TIMEOUT, tag: 0)
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        
        // This method is executed on the socketQueue (not the main thread)
        
        DispatchQueue.main.async {
            let range = Range(uncheckedBounds: (lower: 0, upper: (data.count - 2) )) // This is in place of NSMakeRange
            let strData = data.subdata(in: range)
            
            if let msg = NSString(data: strData, encoding: String.Encoding.utf8.rawValue) {
                (self.viewController as! EchoServerViewController).logMessage(msg: msg as String)
            } else {
                (self.viewController as! EchoServerViewController).logError(msg: "Error converting received data into UTF-8 String")
            }
            
            print("Data being sent: \(NSString(data:strData, encoding: String.Encoding.utf8.rawValue))")
        }
        
        // Echo message back to client
        print("writing data to client...")
        sock.write(data, withTimeout: -1, tag: ECHO_MSG)
        print("Data being sent: \(NSString(data:data, encoding: String.Encoding.utf8.rawValue))")
        print("Sent!")
    }
    
    
    /**
     * This method is called if a read has timed out.
     * It allows us to optionally extend the timeout.
     * We use this method to issue a warning to the user prior to disconnecting them.
     **/
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        if elapsed <= READ_TIMEOUT {
            let warningMsg = "Are you still there?\r\n"
            let warningData = warningMsg.data(using: String.Encoding.utf8)
            
            sock.write(warningData!, withTimeout: -1, tag: WARNING_MSG)
            
            return READ_TIMEOUT_EXTENSION
        }
        
        return 0.0
    }
    
    
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        if (sock != listenSocket) {
            DispatchQueue.main.async {
                (self.viewController as! EchoServerViewController).logInfo(msg: "Client disconnected")
            }
        }
        
        connectedSockets.remove(sock)
    }


}

