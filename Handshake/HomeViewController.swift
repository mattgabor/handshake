//
//  ViewController.swift
//  Handshake
//
//  Created by Matthew Gabor on 10/10/15.
//  Copyright © 2015 Prodigies. All rights reserved.
//

import UIKit
import Parse
import CoreBluetooth
import KVNProgress
import WatchConnectivity
import SDWebImage

class HomeViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate, WCSessionDelegate
{
    // MARK: - Properties
    
    @IBOutlet weak var userLabel: UILabel!
    /* ### iBeacon ### */
    // Will contain all the people around you, if any are around you
    var peopleNearby: [CLBeacon] = []
    // Manages device (peripheral) as iBeacon
    var peripheralManager: CBPeripheralManager?
    // Manages device's location
    var locationManager: CLLocationManager?
    // The last/nearest beacon
    var lastProximity: CLProximity?
    // Payload of data the phone emits as a beacon
    var beaconPeripheralData: NSDictionary?
    // The person who's hand you just Suge Night
    var nearestBeacon: CLBeacon!
    // The dictionary containing the user's info who you just shook hands with
    var nameWithImageDictionary: [String:AnyObject]!
    // A boolean that will notify you if the dictionary has been filled
    var haveFormattedDictionary: Bool!
    // A boolean that will notify you if you have exited the region
    var haveExitedRegion: Bool!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        haveFormattedDictionary = false
        haveExitedRegion = false
        
        (UIApplication.sharedApplication().delegate as! AppDelegate).homeVC = self
        
        // Should never be nil here
        let currentUser = PFUser.currentUser()!
        
        userLabel.text = "Hey \(currentUser.username!)!\n\n Go meet some people 👫"
        
        // Get the minor value from the cached user
        let minorNSNumber = currentUser["minor"] as! NSNumber
        let minor = UInt16(minorNSNumber.intValue)
        
        
        // Set up this phone to detect other beacons
        detectOtherBeacons()
        
        // Set up this phone as an ibeacon
        phoneAsBeacon(0, minor: minor, identifier: "A handshake")
        
//        if (WCSession.isSupported()) {
//            let session = WCSession.defaultSession()
//            session.delegate = self // conforms to WCSessionDelegate
//            session.activateSession()
//        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        (UIApplication.sharedApplication().delegate as! AppDelegate).homeVC = self
        // Dismiss progress view
        if KVNProgress.isVisible()
        {
            KVNProgress.dismiss()
        }
    }
    
    // MARK: - Initialization
    
    // Set up phone as beacon
    func phoneAsBeacon(major: UInt16, minor: UInt16, identifier: String)
    {
        // --- Initialize your phone as a beacon ---
        // 1) Instantiate UUID
        // app uuid - EC36069A-8377-438E-B02F-9A9E78BD6089 (created using uuidgen on the command line)
        let proximityUUID = NSUUID(UUIDString:"EC36069A-8377-438E-B02F-9A9E78BD6089")
        
        // 2) Set up the beacon region
        let phoneBeaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: proximityUUID!, major: major, minor: minor, identifier: identifier)
        
        // 3) Create dictionary of data to be shared across the BlueToothLE signal
        // Create a dictionary of advertisement data.
        self.beaconPeripheralData = phoneBeaconRegion.peripheralDataWithMeasuredPower(nil)
        
        // 4) Start advertising this phone's data
        // Create the peripheral manager.
        let me = self as NSObject
        self.peripheralManager = CBPeripheralManager(delegate: (me as! CBPeripheralManagerDelegate), queue: nil, options: nil)
        
        // Start advertising your beacon's data.
        self.peripheralManager!.startAdvertising((self.beaconPeripheralData! as! [String : AnyObject]))
    }
    
    // Function to detect other phones as iBeacons with a specific uuid
    func detectOtherBeacons()
    {
        // DETECTS OTHER BEACONS
        let uuidString = "EC36069A-8377-438E-B02F-9A9E78BD6089"
        let beaconIdentifier = "A handshake"
        let beaconUUID:NSUUID = NSUUID(UUIDString: uuidString)!
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID,
            identifier: beaconIdentifier)
        
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization"))
        {
            locationManager!.requestAlwaysAuthorization()
            //println("Registered location permissions")
        }
        else
        {
            //println("Did not get location permissions")
        }
        locationManager!.delegate = self as CLLocationManagerDelegate
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoringForRegion(beaconRegion)
        locationManager!.startRangingBeaconsInRegion(beaconRegion)
        locationManager!.startUpdatingLocation()

    }
    
    
    // MARK: - CLLocationManagerDelegate Protocol
    
    func peripheralManagerIsReadyToUpdateSubscribers()
    {
        print("peripheral manager is ready to update subscribers")
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion)
    {
        if(beacons.count > 0)
        {
            print("Found someone by you")
            nearestBeacon = beacons[0]
            self.userLabel.text = "About to send local notification"
            // Send local notification, or send remote from parse
            let nameReminder = UILocalNotification()
            nameReminder.userInfo = nameWithImageDictionary
            UIApplication.sharedApplication().scheduleLocalNotification(nameReminder)
            
            switch nearestBeacon.proximity
            {
                case CLProximity.Immediate:
                    print("Immediate range")
                    //userLabel.text = "PERSON BY YOU IMMEDIATE!!"
                case CLProximity.Near:
                    print("Near you")
                case CLProximity.Far:
                    print("Far!!")
                    //if haveFormattedDictionary! == true
                    //{
                
                    //}
                default: break
                
            }
            
        } else {
            // Reset
            //self.nearestBeacon = CLBeacon()
        }
    }
    
    
    func locationManager(manager: CLLocationManager,
        didEnterRegion region: CLRegion) {
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            
            NSLog("You entered the region")
            //sendLocalNotificationWithMessage("You entered the region")
    }
    
    func locationManager(manager: CLLocationManager,
        didExitRegion region: CLRegion) {
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            // Send notification to phone now
            //self.sendShakerDataToWatch(self.nameWithImageDictionary)
            
//            // Pray the query finishes in time
//            //self.haveExitedRegion = true
//            
//            NSLog("You exited the region")
//            
//            // Send with the actual data
//            sendLocalNotificationWithMessage("You exited the region")
    }

    // MARK: - CBPeripheralManagerDelegate Protocol
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        if (peripheral.state == CBPeripheralManagerState.PoweredOn)
        {
            //println("Powered On")
            self.peripheralManager!.startAdvertising((self.beaconPeripheralData! as! [String : AnyObject]))
        }
        else if (peripheral.state == CBPeripheralManagerState.PoweredOff)
        {
            //println("Powered Off")
            self.peripheralManager!.stopAdvertising()
        }
    }
    
    // MARK: - Message Passing/Receiving To Watch
    
    func sendShakerDataToWatch(data: [String:AnyObject]) {
        
        // check the reachablity
        if WCSession.defaultSession().reachable == false {
            
            let alert = UIAlertController(
                title: "Failed to send",
                message: "Apple Watch is not reachable.",
                preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil)
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        print("Sending message to watch")
        
        // Send this message to the watch
        WCSession.defaultSession().sendMessage(
            data, replyHandler: { (replyMessage) -> Void in
            }) { (error) -> Void in
                print(error)
        }
    }
    
    func queryParseForShaker()
    {
        //print("Fuckk")
    }
    
    // MARK: - Utils
    
    func sendLocalNotificationWithMessage(message: String!)
    {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}