//
//  Event.swift
//  beaconRooms
//
//  Created by Mik Jensen on 9/16/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

class Event: NSObject {
    var summary:String?
    var start:NSDate
    var end:NSDate
    var booked:Bool
    var owner:String
    var rows:Int
    var eventId:String
    var attendees:[AnyObject]
    
    init(summary:String, start:NSDate, end:NSDate, booked:Bool, owner:String, rows:Int, eventId: String, attendees:[AnyObject]){
        self.summary = summary
        self.start = start
        self.end = end
        self.booked = booked
        self.owner = owner
        self.rows = rows
        self.eventId = eventId
        self.attendees = attendees
    }
}
