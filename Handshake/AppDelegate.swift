//
//  AppDelegate.swift
//  Handshake
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

import UIKit
import Parse
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("BZgVVYapIDNl3kVbOg0nY7UgHs8wfGGjGavd2zL6", clientKey: "qp6o8o0uoffnmEfkFFS3YLUexHEX9gNmmkpUDHq5")
        // Override point for customization after application launch.
        
        
        let settings = UIUserNotificationSettings(
            forTypes: [.Badge, .Sound, .Alert],
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        //UIApplicatio
        
        if (WCSession.isSupported())
        {
            let session = WCSession.defaultSession()
            session.delegate = self // conforms to WCSessionDelegate
            session.activateSession()
        }
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: [.Alert, .Sound],
                    categories: nil)
            )
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func sessionWatchStateDidChange(session: WCSession) {
        print(__FUNCTION__)
        print(session)
        print("reachable:\(session.reachable)")
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        /// REPLACE THIS WITH YO PARSE CODEZ MOTHA LICKA
        
        print(__FUNCTION__)
        guard message["request"] as? String == "fireLocalNotification" else {return}
        
        let localNotification = UILocalNotification()
        localNotification.alertBody = "Handshake Executed"
        localNotification.fireDate = NSDate()
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)

    }

}

