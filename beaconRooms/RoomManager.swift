//
//  RoomManager.swift
//  beaconRooms
//
//  Created by Mik Jensen on 10/18/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class RoomManager: NSObject {
    var view:UIViewController?
    var beaconsDB = [Beacon]()
    
    // The google sheets document with beacon values
    // https://docs.google.com/spreadsheets/d/1S0CrIrvXsSrbhNFEYZgSYYqVKBb4HAVw9ht2G_WCCk0/edit
    func listBeacons(vc: UIViewController?) {
        self.view = vc
        
        beaconsDB.removeAll()
        
        let baseUrl = "https://sheets.googleapis.com/v4/spreadsheets"
        let spreadsheetId = "1S0CrIrvXsSrbhNFEYZgSYYqVKBb4HAVw9ht2G_WCCk0"
        let range = "A:E"
        let url = String(format:"%@/%@/values/%@", baseUrl, spreadsheetId, range)
        let params = ["majorDimension": "ROWS"]
        let fullUrl = GTLUtilities.URLWithString(url, queryParameters: params)
        GoogleAPIManager.service.fetchObjectWithURL(fullUrl,
                                                    objectClass: GTLObject.self,
                                                    delegate: view,
                                                    didFinishSelector: #selector(displayResultWithTicket(_:finishedWithObject:error:)))
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject object : GTLObject, error : NSError?) {
        if let error = error {
            GoogleAPIManager.showAlert("Error", message: error.localizedDescription, view: view!)
            return
        }
        
        let rows = object.JSON["values"] as! [[String]]
        
        if rows.isEmpty {
            GoogleAPIManager.showAlert("Error", message: "No data found.", view: view!)
            return
        }
        
        for i in (0..<rows.count){
            if i > 0{
                let uuid = rows[i][0]
                let major = rows[i][1]
                let minor = rows[i][2]
                let title = rows[i][3]
                let calendarId = rows[i][4]
                
                self.beaconsDB.append(Beacon(uuid: uuid, major: Int(major)!, minor: Int(minor)!, title: title, calendarId: calendarId))
            }
        }
    }
}
