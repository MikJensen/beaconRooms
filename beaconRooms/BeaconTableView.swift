//
//  BeaconTableView.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/24/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class BeaconTableView: UITableViewController {
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    let app = AppDelegate()
    let roomManager = RoomManager()
    var beaconsDB = [Beacon]()
    
    var indexPathSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        GoogleAPIManager.getGoogleAPIAuthFromKeychain()
        GoogleAPIManager.validateGoogleAPIAuth(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return app.beaconsDB.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellRooms", forIndexPath: indexPath)
        
        let title = app.beaconsDB[indexPath.row].title
        
        cell.textLabel!.text = "\(title)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToSchedule", sender: indexPath)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToSchedule"{
            if let destinationVC = segue.destinationViewController as? ScheduleVC{
                let indexPath = sender as! NSIndexPath
                destinationVC.beaconObj = app.beaconsDB[indexPath.row]
            }
        }
    }
}
