//
//  AppDelegate.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/24/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

    var window: UIWindow?

    let beaconManager = ESTBeaconManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        for b in Rooms.beaconsDB {
            self.beaconManager.startMonitoringForRegion(CLBeaconRegion(
                proximityUUID: NSUUID(UUIDString: b.uuid)!,
                major: CLBeaconMajorValue(b.major), minor: CLBeaconMinorValue(b.minor), identifier: b.title))
        }
        
        
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert, categories: nil))

        UINavigationBar.appearance().backIndicatorImage = UIImage()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
        UINavigationBar.appearance().barTintColor = UIColor(red: 254/255, green: 82/255, blue: 124/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-20, 0), forBarMetrics: UIBarMetrics.Default)
        
        return true
    }
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        let beacon = Rooms.beaconsDB[Rooms.beaconsDB.indexOf(Beacon(major: Int(region.major!), minor: Int(region.minor!)))!]
        let date = NSDate()
        GoogleAPIManager.fetchEvents(nil, room: beacon.calendarId) {
            (events) in
            
            let eventsArr = ScheduleManager.getTimeSheet(date, events: events)
            if eventsArr.count > 1{
                let eventNow = eventsArr[0]
                let eventNext = eventsArr[1]
                
                let notification = UILocalNotification()
                if eventNow.booked{
                    notification.alertBody = "\(beacon.title) is booked! \(eventNow.start.getTimeOfDate()) - \(eventNow.end.getTimeOfDate())\nBy: \(eventNow.owner)"
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                }else if !eventNow.booked && eventNext.booked{
                    notification.alertBody = "\(beacon.title) is free untill \(eventNext.start.getTimeOfDate())\nWhere its booked by \(eventNext.owner)"
                    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                }
            }
        }
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
        // Saves changes in the application's managed object context before the application terminates.
    }

}

