//
//  BeaconManager.swift
//  beaconRooms
//
//  Created by Mik Jensen on 9/16/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class BeaconManager: NSObject {
    static var vc:UIViewController?
    
    static var beacons = [Beacon]()
    
    static func loadData(vc: UIViewController){
        self.vc = vc
        beacons.removeAll()
    }
}
