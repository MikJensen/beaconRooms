//
//  AppDelegate.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/24/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

    var window: UIWindow?

    let beaconManager = ESTBeaconManager()
    
    let beaconsDB = [
        Beacon(uuid: "3A9866C0-64A2-425D-AFC0-777C9D7C255D", major: 26570, minor: 21185, title: "DK - Meeting room 1", calendarId: "nodes.dk_2d333732343533322d373933@resource.calendar.google.com"),
        Beacon(uuid: "3A9866C0-64A2-425D-AFC0-777C9D7C255D", major: 52075, minor: 16686, title: "DK - Meeting room 2", calendarId: "nodes.dk_3937343632353031343735@resource.calendar.google.com"),
        Beacon(uuid: "3A9866C0-64A2-425D-AFC0-777C9D7C255D", major: 62738, minor: 43687, title: "DK - Meeting room 3", calendarId: "nodes.dk_2d393737303335332d353839@resource.calendar.google.com"),
        Beacon(uuid: "3A9866C0-64A2-425D-AFC0-777C9D7C255D", major: 43556, minor: 47687, title: "DK - Meeting room 4", calendarId: "nodes.dk_39373635333035383336@resource.calendar.google.com"),
        Beacon(uuid: "3A9866C0-64A2-425D-AFC0-777C9D7C255D", major: 52719, minor: 38783, title: "DK - Playroom", calendarId: "nodes.dk_2d3834363137383533343434@resource.calendar.google.com")
    ]

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        for b in beaconsDB {
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
        //let date = NSDate()
        let beacon = beaconsDB[beaconsDB.indexOf(Beacon(major: Int(region.major!), minor: Int(region.minor!)))!]
        let date = NSDate()
        GoogleAPIManager.fetchOneEvent(date, room: beacon.calendarId) {
            (events) in
            if let events = events{
                var scheduleArr = [NSDate]()
                let time = date.getTimeOfDate()
                var scheduleDate:NSDate?
                if Int(time.componentsSeparatedByString(":").last!)! > 30{
                    scheduleDate = "\(date.customFormatted()) \(time.componentsSeparatedByString(":").first!):30".asDate
                }else{
                    scheduleDate = "\(date.customFormatted()) \(time.componentsSeparatedByString(":").first!):00".asDate
                }
                scheduleArr.append(scheduleDate!)
                let eventsArr = ScheduleManager.checkOneEvent(events, timeScheduleArr: scheduleArr, date: date)
                let event = eventsArr[0]
                
                if event.owner == GoogleAPIManager.user{
                    let notification = UILocalNotification()
                    notification.alertBody = "\(beacon.title) is booked! \(event.start.getTimeOfDate()) - \(event.end.getTimeOfDate())\nBy \(event.owner)"
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

