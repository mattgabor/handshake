//
//  InterfaceController.swift
//  Handshake WatchKit Extension
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    let motionManager = CMMotionManager()
    var pushSent = false
    @IBOutlet var resetButton: WKInterfaceButton!

    // MARK: - Accelerometer Code
    override func willActivate() {
        super.willActivate()
        
        // DO NOT RESET
        
        
        if (motionManager.accelerometerAvailable == true) {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                self.resetButton.setBackgroundColor(UIColor.clearColor())
                let currentNumber = ((NSString(format: "%.5f", data!.acceleration.x)).doubleValue * 100)
                if currentNumber < 10 && !self.pushSent {
                    // Send notification to watch to look up minor from Parse
                    print(currentNumber)
                    print("sending push")
                    let message = ["request": "fireLocalNotification"]
                    WCSession.defaultSession().sendMessage(
                        message, replyHandler: { (replyMessage) -> Void in
                        }) { (error) -> Void in
                            print(error.localizedDescription)
                    }
                    self.pushSent = true
                }
//                } else if currentNumber > 60 && self.pushSent {
//                    print(currentNumber)
//                    print("resetting push")
//                    self.pushSent = false
//                }
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        else {
            print("Accelerometer not available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
    }
    
    // MARK: - Message Passing Code
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Activate the session on both sides to enable communication.
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self // conforms to WCSessionDelegate
            session.activateSession()
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        // Configure interface objects here.
    }
    
    // Received message from iPhone
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        let shakerName = message["name"]
        
        print(__FUNCTION__)
        guard message["request"] as? String == "showAlert" else {return}
        
        let defaultAction = WKAlertAction(
            title: "Save Contact",
            style: WKAlertActionStyle.Default) { () -> Void in
        }
        let actions = [defaultAction]
        
        self.presentAlertControllerWithTitle(
            "\(shakerName)",
            message: "",
            preferredStyle: WKAlertControllerStyle.SideBySideButtonsAlert,
            actions: actions)
    }
    
    // MARK: - Actions
    
    @IBAction func reset()
    {
        resetButton.setBackgroundColor(UIColor.redColor())
        self.pushSent = false
    }
}
