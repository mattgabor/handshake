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

class HomeViewController: UIViewController, CBPeripheralManagerDelegate, CLLocationManagerDelegate
{
    // MARK: - Properties
    
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

    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Should never be nil here
        let currentUser = PFUser.currentUser()!
        
        // Get the minor value from the cached user
        let minorNSNumber = currentUser["minor"] as! NSNumber
        let minor = UInt16(minorNSNumber.intValue)
        
        // Set up this phone as an ibeacon
        phoneAsBeacon(0, minor: minor, identifier: "A handshake")
    }
    
    override func viewDidAppear(animated: Bool)
    {
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
    
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager,
        didRangeBeacons beacons: [CLBeacon],
        inRegion region: CLBeaconRegion) {
            //NSLog("didRangeBeacons");
            //var message:String = ""
            
            //println("Beacons count: \(beacons.count)")
            
            if(beacons.count > 0)
            {
                // Pass beacons to home screen
                self.peopleNearby = beacons
                
                let nearestBeacon:CLBeacon = beacons[0]
                
                if(nearestBeacon.proximity == lastProximity ||
                    nearestBeacon.proximity == CLProximity.Unknown)
                {
                    return;
                }
                
                lastProximity = nearestBeacon.proximity;
                
                if nearestBeacon.proximity == CLProximity.Immediate
                {
                    
                }
                
                var ids = [NSNumber]()
                
                for beacon: CLBeacon in beacons
                {
                    ids.append(beacon.minor)
                }
                
                let query = PFQuery(className: "_User")
                
                query.whereKey("minor", containedIn: ids)
                
                query.findObjectsInBackgroundWithBlock
                {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if  error == nil
                    {
                        for object in objects!
                        {
                            let shakerName = object["minor"] as! String
                            print("You are nearby \(shakerName)!!!")
                        }
                    }
                    else
                    {
                        print("Error querying for beacon minor with error: \(error!.description)")
                    }
                }
                
                //                switch nearestBeacon.proximity {
                //                case CLProximity.Far:
                //                    message = "You are far away from the beacon"
                //                case CLProximity.Near:
                //                    message = "You are near the beacon"
                //                case CLProximity.Immediate:
                //                    message = "You are within range to P.I.N.G."}
                //case CLProximity.Unknown:
                //  return
                
                //            } else {
                //                message = "No beacons are nearby"
            }
            else
            {
                // Stop glowing of the beacon button, need to check if animation exists before??
                //                if beaconsButton.layer.animationKeys().count > 0
                //                {
                //                    beaconsButton.layer.removeAllAnimations()
                //
                //                }
                // Clear array
                self.peopleNearby = []
                //message = "No beacons nearby"
            }
            
            //NSLog("%@", message)
            //sendLocalNotificationWithMessage(message)
    }
    
    func locationManager(manager: CLLocationManager,
        didEnterRegion region: CLRegion) {
            manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            
            //NSLog("You entered the region")
            //sendLocalNotificationWithMessage("You entered the region")
    }
    
    func locationManager(manager: CLLocationManager,
        didExitRegion region: CLRegion) {
            manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
            manager.stopUpdatingLocation()
            
            // Send notification to phone now
            
            
            // NSLog("You exited the region")
            // sendLocalNotificationWithMessage("You exited the region")
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

    
}

