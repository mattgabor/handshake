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


class InterfaceController: WKInterfaceController {
    
    let coreyMinor = 40769
    let motionManager = CMMotionManager()
    
    @IBOutlet var shookLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        
        
        motionManager.accelerometerUpdateInterval = 0.1
        // Configure interface objects here.
    }

    override func willActivate() {
        super.willActivate()
        
        if (motionManager.accelerometerAvailable == true) {
            let handler:CMAccelerometerHandler = {(data: CMAccelerometerData?, error: NSError?) -> Void in
                let currentNumber = ((NSString(format: "%.5f", data!.acceleration.x)).doubleValue * 100)
                if currentNumber > 0 {
                    self.shookLabel.setText("Shook")
                    // Look up minor in DB and prepare to present notification
                }
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
    
    func registerHandshake() {
        
    }

}
