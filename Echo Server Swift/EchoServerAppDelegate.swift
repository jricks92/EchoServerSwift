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

    // MARK: Class Variables
    
    let socketQueue = DispatchQueue(label: "socketQueue")
    
    var listenSocket = GCDAsyncSocket()
    var connectedSockets = NSMutableArray(capacity: 1)

    
    override init() {
        super.init()
        listenSocket = GCDAsyncSocket(delegate: self, delegateQueue: socketQueue)
    }
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }


}

