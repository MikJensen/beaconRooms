//
//  Beacon.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/25/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

struct Beacon: Equatable {
    var uuid: String = ""
    var major: Int = 0
    var minor: Int = 0
    var title: String = ""
    var calendarId:String = ""
    
    init(uuid: String, major: Int, minor: Int, title: String, calendarId: String){
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.title = title
        self.calendarId = calendarId
    }
    init(major:Int, minor:Int){
        self.major = major
        self.minor = minor
    }
}
func ==(lhs: Beacon, rhs: Beacon)->Bool{
    return lhs.major == rhs.major &&
            lhs.minor == rhs.minor
}
