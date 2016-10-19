//
//  ScheduleTableViewController.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/30/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class ScheduleTableViewController: UITableViewController {
    
    var date = NSDate()
    
    var beaconObj:Beacon!
    
    var timeSheet = [Booked]()
    var eventsArr = [GTLCalendarEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvents(beaconObj.title)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = NSDate().customFormatted(date)
    }
    
    @IBAction func nextButton(sender: AnyObject) {
        performSegueWithIdentifier("segueNext", sender: self)
    }
    
    func reloadTimeSheet(){
        timeSheet.removeAll()
        timeSheet = ScheduleManager.getTimeSheet(beaconObj.title, date: date, events: eventsArr)
        tableView.reloadData()
    }
    
    func fetchEvents(room: String){
        eventsArr.removeAll()
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId(beaconObj.calendarId)
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        GoogleAPIManager.service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(ScheduleTableViewController.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    func displayResultWithTicket(ticket: GTLServiceTicket, finishedWithObject response : GTLCalendarEvents, error : NSError?) {
        if let error = error {
            GoogleAPIManager.showAlert("Error", message: error.localizedDescription, view: self)
            return
        }
        
        if let events = response.items() where !events.isEmpty {
            for event in events as! [GTLCalendarEvent] {
                eventsArr.append(event)
            }
        }
        reloadTimeSheet()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return timeSheet.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSchedule", forIndexPath: indexPath)

        let time = timeSheet[indexPath.row].time as NSDate
        let owner = timeSheet[indexPath.row].owner as String
        
        if timeSheet[indexPath.row].booked{
            cell.backgroundColor = UIColor.redColor()
            cell.textLabel?.text = "\(time.getTimeOfDate(time)) - \(owner)"
        }else{
            cell.backgroundColor = UIColor.greenColor()
            cell.textLabel?.text = time.getTimeOfDate(time)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var message = ""
        
        if timeSheet[indexPath.row].booked{
            message = "Room is booked!"
            alertBox(message, booked: true, indexPath: indexPath)
        }else{
            message = "Book room from \(timeSheet[indexPath.row].time) to \(timeSheet[indexPath.row+1].time)"
            alertBox(message, booked: false, indexPath: indexPath)
        }
    }
    
    func alertBox(message: String,booked: Bool, indexPath: NSIndexPath){
        let alert = UIAlertController(title: "Book room", message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        
        let Deselect = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        alert.addAction(Deselect)
        
        if booked{
            let Unbook = UIAlertAction(title: "Unbook", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                self.reloadTimeSheet()
            }
            alert.addAction(Unbook)
            
        }else{
            let Book = UIAlertAction(title: "Book", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction) -> Void in
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                self.reloadTimeSheet()
            }
            alert.addAction(Book)
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueNext"{
            if let destinationVC = segue.destinationViewController as? ScheduleTableViewController{
                destinationVC.beaconObj = beaconObj
                destinationVC.date = NSDate().nextDay(date)
            }
        }
    }
}
