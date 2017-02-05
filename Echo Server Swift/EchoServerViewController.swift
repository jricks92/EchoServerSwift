//
//  ViewController.swift
//  Echo Server Swift
//
//  Created by Jameson Ricks on 2/4/17.
//  Copyright © 2017 Jameson Ricks. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

struct Constants {
    static let WELCOME_MSG = 0
    static let ECHO_MSG = 1
    static let WARNING_MSG = 2
    
    static let READ_TIMEOUT = 15.0
    static let READ_TIMEOUT_EXTENSION = 10.0
}

class EchoServerViewController: NSViewController {
    
    // MARK: Class Variables
    
    var isRunning = false
    
    // MARK: Outlets
    
    @IBOutlet var logView: NSTextView!
    @IBOutlet weak var startStopButton: NSButton!
    @IBOutlet weak var portField: NSTextField!
    
    
    // MARK: View Controller Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: Actions

    @IBAction func startStop(_ sender: Any) {
        
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        
        if (!isRunning) {
            var port = 0
            
            if let portValue = Int(portField.stringValue) {
                port = portValue
            }
            
            if (port < 0 || port > 65535) {
                portField.stringValue = "0"
            }
            
            do {
                try appDelegate.listenSocket.accept(onPort: UInt16(port))
            } catch {
                self.logError(msg: "Error starting server on port \(port)")
            }
            
            self.logInfo(msg: "Echo server started on port \(appDelegate.listenSocket.localPort)")
            
            isRunning = true
            
            portField.isEnabled = false
            startStopButton.title = "Stop"
        } else {
            // Stop accepting connections
            appDelegate.listenSocket.disconnect()
            
            // Stop any client connections
            for s in appDelegate.connectedSockets {
                (s as! GCDAsyncSocket).disconnect()
            }
            
            self.logInfo(msg: "Stopped Echo server")
            isRunning = false
            
            portField.isEnabled = true
            startStopButton.title = "Start"
        }
    }
    
    // MARK: Helper Functions
    func scrollToBottom() {
        let scrollView = self.logView.enclosingScrollView
        let newScrollOrigin : NSPoint
        
        if (scrollView?.documentView?.isFlipped)! {
            newScrollOrigin = NSMakePoint(0.0, NSMaxY((scrollView?.documentView?.frame)!))
        } else {
            newScrollOrigin = NSMakePoint(0.0, 0.0)
        }
        
        scrollView?.documentView?.scroll(newScrollOrigin)
    }
    
    func logError(msg : String) {
        let paragraph = String(format: "%@\n", msg)
        
        let attributes = [NSForegroundColorAttributeName: NSColor.red]
        
        let attributed = NSAttributedString(string: paragraph, attributes: attributes)
        
        logView.textStorage?.append(attributed)
    }
    
    func logInfo(msg : String) {
        let paragraph = String(format: "%@\n", msg)
        
        let attributes = [NSForegroundColorAttributeName: NSColor.purple]
        
        let attributed = NSAttributedString(string: paragraph, attributes: attributes)
        
        logView.textStorage?.append(attributed)
    }
    
    func logMessage(msg : String) {
        let paragraph = String(format: "%@\n", msg)
        
        let attributes = [NSForegroundColorAttributeName: NSColor.black]
        
        let attributed = NSAttributedString(string: paragraph, attributes: attributes)
        
        logView.textStorage?.append(attributed)
    }
    
    

}

