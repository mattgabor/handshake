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
    
    let coreyMinor = 40769
    let motionManager = CMMotionManager()
    var pushSent = false
    
    // MARK: - Accelerometer Code
    override func willActivate() {
        super.willActivate()
        
        if (motionManager.accelerometerAvailable == true) {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                let currentNumber = ((NSString(format: "%.5f", data!.acceleration.x)).doubleValue * 100)
                
                if currentNumber < 0 && !self.pushSent {
                    self.readHandshake(currentNumber)
                } else if currentNumber > 60 {
                    self.pushSent = false
                }
                // on 60 trigger reset, 0 trigger initial read.
            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        else {
            print("Accelerometer not available")
        }
    }
    
    func readHandshake(currentNumber: Double) {
        // Send notification to watch to look up minor from Parse
        print("sending push notification to iPhone")
        let message = ["request": "fireLocalNotification"]
        WCSession.defaultSession().sendMessage(
            message, replyHandler: { (replyMessage) -> Void in
            }) { (error) -> Void in
                print(error.localizedDescription)
        }
        self.pushSent = true
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
        print(__FUNCTION__)
        guard message["request"] as? String == "showAlert" else {return}
        
        let defaultAction = WKAlertAction(
            title: "Save Contact",
            style: WKAlertActionStyle.Default) { () -> Void in
        }
        let actions = [defaultAction]
        
        self.presentAlertControllerWithTitle(
            "Corey Ching",
            message: "",
            preferredStyle: WKAlertControllerStyle.Alert,
            actions: actions)
    }
    func registerHandshake() {
        
    }

}
