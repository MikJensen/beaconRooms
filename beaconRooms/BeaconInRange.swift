//
//  BeaconInRange.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/25/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

class BeaconInRange: NSObject {
    var uuid: String
    var major: Int
    var minor: Int
    var name: String
    var booked: Bool
    
    init(uuid: String, major: Int, minor: Int, name: String, booked: Bool){
        self.uuid = uuid
        self.major = major
        self.minor = minor
        self.name = name
        self.booked = booked
    }
}
