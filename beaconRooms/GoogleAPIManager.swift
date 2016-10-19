//
//  GoogleAPIManager.swift
//  GoogleCalendarTest
//
//  Created by Mik Jensen on 9/14/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class GoogleAPIManager: NSObject{
    private static let kKeychainItemName = "Google API"
    private static let kClientID = "883539920849-tncfa30h32481uc087ipgevh1bmvdvhj.apps.googleusercontent.com"

    private static let scopeCalendar = [kGTLAuthScopeCalendar]
    //private static let scopeSheet = ["https://www.googleapis.com/auth/spreadsheets"]
    private static let scopeContact = ["https://www.google.com/m8/feeds"]
    private static let scopeUser = ["https://www.googleapis.com/auth/userinfo.profile"]
    
    static var user = ""
    
    static let service = GTLServiceCalendar()
    
    private static var tempContacts = [String]()
    
    static func getGoogleAPIAuthFromKeychain(){
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
            if let email = auth.userEmail{
                user = email
            }
        }
    }
    
    static func removeGoogleAPIAuthFromKeychain(view: UIViewController){
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName(kKeychainItemName)
        service.authorizer = nil
        validateGoogleAPIAuth(view)
    }
    
    static func validateGoogleAPIAuth(view: UIViewController){
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
        } else {
            view.presentViewController(
                createAuthController(view),
                animated: true,
                completion: nil
            )
        }
    }
    
    private static func createAuthController(view: UIViewController) -> GTMOAuth2ViewControllerTouch {
        let scopeString = "\(scopeCalendar.joinWithSeparator(" ")) \(scopeContact.joinWithSeparator(" ")) \(scopeUser.joinWithSeparator(" ")) "
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: view,
            finishedSelector: #selector(finishWithAuth(_:authResult:error:))
        )
    }
    
    static func finishWithAuth(vc: UIViewController, authResult : GTMOAuth2Authentication, error : NSError?){
        if let error = error {
            GoogleAPIManager.service.authorizer = nil
            GoogleAPIManager.showAlert("Authentication Error", message: error.localizedDescription, view: vc)
            return
        }
        vc.dismissViewControllerAnimated(false, completion: nil)
        vc.removeFromParentViewController()
        
        GoogleAPIManager.service.authorizer = authResult
    }
    
    static func getContacts(ch:(contacts: [String])->Void){
        let url = NSURL(string: "https://www.google.com/m8/feeds/contacts/default/full//?max-results=\(999)&alt=json&v=3")
        let urlRequest = NSMutableURLRequest(URL: url!)
        
        service.authorizer.authorizeRequest!(urlRequest, completionHandler: {
            (error) in
            if error != nil {
                print("error on getting contact: \(error?.localizedDescription)")
                return
            } else {
                let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>=nil
                do{
                    let dataVal = try NSURLConnection.sendSynchronousRequest(urlRequest, returningResponse: response)
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(dataVal, options: []) as? NSDictionary {
                            getEmail(jsonResult)
                            ch(contacts: tempContacts)
                            tempContacts.removeAll()
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }catch let error as NSError
                {
                    print(error.localizedDescription)
                }
                
            }
        })
    }
    
    private static func getEmail(dict: NSDictionary){
        for d in dict{
            let key = d.key as! String
            if key == "address"{
                tempContacts.append(d.value as! String)
            }else{
                if key == "entry" || key == "gd$email"{
                    for i in d.value as! NSArray{
                        if let newDict = i as? NSDictionary{
                            getEmail(newDict)
                        }
                    }
                }else{
                    if let value = d.value as? NSDictionary{
                        getEmail(value)
                    }
                }
            }
        }
    }
    
    static func createAttendee(organizer: Bool, resource: Bool, email: String)->GTLCalendarEventAttendee{
        let attendee = GTLCalendarEventAttendee()
        if organizer{
            attendee.organizer = true
            attendee.responseStatus = "accepted"
        }
        else if resource{attendee.resource = true}
        attendee.email = email
        return attendee
    }
    
    // MARK: CRUD Events
    
    static func createEvent(eventObj: Event, beaconObj: Beacon, vc: UIViewController, ch:(returnValue: Bool)->Void){
        let event = GTLCalendarEvent()
        
        event.summary = eventObj.summary
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startEvent = GTLCalendarEventDateTime()
        startEvent.dateTime = GTLDateTime(date: eventObj.start, timeZone: NSTimeZone.localTimeZone())
        let endEvent = GTLCalendarEventDateTime()
        endEvent.dateTime = GTLDateTime(date: eventObj.end, timeZone: NSTimeZone.localTimeZone())
        
        event.start = startEvent
        event.end = endEvent
        
        event.location = beaconObj.title
        
        var attendeesArr = [GTLCalendarEventAttendee]()
        
        attendeesArr.append(createAttendee(false, resource: true, email: beaconObj.calendarId))
        attendeesArr.append(createAttendee(true, resource: false, email: GoogleAPIManager.user))
        for e in eventObj.attendees{
            attendeesArr.append(e as! GTLCalendarEventAttendee)
        }
        
        event.attendees = attendeesArr
        
        let query = GTLQueryCalendar.queryForEventsInsertWithObject(event, calendarId: "primary")
        query.sendNotifications = true
        self.service.executeQuery(query) {
            (ticket, response, error) in
            if error == nil{
                ch(returnValue: true)
            }else{
                ch(returnValue: false)
                self.showAlert("Error", message: error.localizedDescription, view: vc)
            }
        }
    }
    
    static func fetchEvents(vc: UIViewController?, room: String, ch:(events: [GTLCalendarEvent])->Void){
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId(room)
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        GoogleAPIManager.service.executeQuery(query) {
            (ticket, response, error) in
            
            if let error = error, let vc = vc {
                GoogleAPIManager.showAlert("Error", message: error.localizedDescription, view: vc)
                return
            }
            
            var eventsArr = [GTLCalendarEvent]()
            if let events = response.items() where !events.isEmpty {
                for event in events as! [GTLCalendarEvent] {
                    eventsArr.append(event)
                }
            }
            ch(events: eventsArr)
        }
    }
    
    static func updateEvent(eventObj: Event, beaconObj: Beacon, vc: UIViewController, ch:(returnValue:Bool)->Void){
        let event = GTLCalendarEvent()
        
        event.summary = eventObj.summary
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startEvent = GTLCalendarEventDateTime()
        startEvent.dateTime = GTLDateTime(date: eventObj.start, timeZone: NSTimeZone.localTimeZone())
        let endEvent = GTLCalendarEventDateTime()
        endEvent.dateTime = GTLDateTime(date: eventObj.end, timeZone: NSTimeZone.localTimeZone())
        
        event.start = startEvent
        event.end = endEvent
        
        event.location = beaconObj.title
        
        event.attendees = eventObj.attendees
        
        let query = GTLQueryCalendar.queryForEventsUpdateWithObject(event, calendarId: "primary", eventId: eventObj.eventId)
        query.sendNotifications = true
        self.service.executeQuery(query) {
            (ticket, response, error) in
            if error == nil{
                ch(returnValue: true)
            }else{
                ch(returnValue: false)
                self.showAlert("Error", message: error.localizedDescription, view: vc)
            }
        }
    }
    
    static func deleteEvent(eventObj: Event, vc: UIViewController, ch:(returnValue:Bool)->Void){
        let query = GTLQueryCalendar.queryForEventsDeleteWithCalendarId("primary", eventId: eventObj.eventId)
        query.sendNotifications = true
        self.service.executeQuery(query) {
            (ticket, response, error) in
            if error == nil{
                ch(returnValue: true)
            }else{
                ch(returnValue: false)
                self.showAlert("Error", message: error.localizedDescription, view: vc)
            }
        }
    }
    
    // MARK: Alert
    
    static func showAlert(title : String, message: String, view: UIViewController) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        view.presentViewController(alert, animated: true, completion: nil)
    }

}
