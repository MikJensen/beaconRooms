//
//  ScheduleVC.swift
//  beaconRooms
//
//  Created by Mik Jensen on 9/20/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableViewSchedule: UITableView!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var date = NSDate()
    
    var beaconObj:Beacon!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    var timeSheet = [Event]()
    
    var selectedRows = [Event](){
        didSet{
            selectedRows.sortInPlace({$0.start.compare($1.start) == .OrderedAscending})
            setBarButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomTitleLabel.text = beaconObj.title
        
        tableViewSchedule.delegate = self
        tableViewSchedule.dataSource = self
        
        tableViewSchedule.allowsMultipleSelection = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScheduleVC.refreshNotification(_:)), name:"refresh", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTimeSheet()
        
        self.view.addSubview(activityIndicator)
        
        navigationItem.title = date.customFormatted()
        setBarButton()
        selectedRows.removeAll()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Buttons action
    
    @IBAction func addPressed(sender: AnyObject) {
        performSegueWithIdentifier("segueEvent", sender: Event(summary: "", start: (selectedRows.first?.start)!, end: (selectedRows.last?.end)!, booked: false, owner: "", rows: 0, eventId: "", attendees: []))
        selectedRows.removeAll()
        tableViewSchedule.reloadData()
    }
    
    func setBarButton(){
        let nextDay = date.nextDay()
        nextButton.title = "\(nextDay.customFormatted())"
        addButton.layer.cornerRadius = 4
        
        if selectedRows.count > 0{
            addButton.hidden = false
            nextButton.enabled = false
        }else{
            addButton.hidden = true
            nextButton.enabled = true
        }
    }
    
    // MARK: - Fetch data
    
    func refreshNotification(notification: NSNotification){
        loadTimeSheet()
    }
    
    func loadTimeSheet(){
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        timeSheet.removeAll()
        
        GoogleAPIManager.fetchEvents(self, room: beaconObj.calendarId) {
            (events) in
            self.timeSheet = ScheduleManager.getTimeSheet(self.date, events: events)
            self.tableViewSchedule.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeSheet.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let eventObj = timeSheet[indexPath.row]
        if eventObj.booked{
            return CGFloat(30*eventObj.rows)
        }else{
            return 30
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSchedule", forIndexPath: indexPath)
        
        cell.textLabel?.font = UIFont(name: "Futura", size: 12)!
        
        let start = timeSheet[indexPath.row].start as NSDate
        let end = timeSheet[indexPath.row].end as NSDate
        let owner = timeSheet[indexPath.row].owner as String
        let title = timeSheet[indexPath.row].summary! as String
        let attendees = timeSheet[indexPath.row].attendees as! [GTLCalendarEventAttendee]
        
        if timeSheet[indexPath.row].booked{
            cell.backgroundColor = UIColor(red: 254/255, green: 82/255, blue: 124/255, alpha: 1.0) // Pink
            cell.textLabel?.numberOfLines = timeSheet[indexPath.row].rows
            
            if timeSheet[indexPath.row].rows > 2{
                cell.textLabel?.text = "\(start.getTimeOfDate()) - \(end.getTimeOfDate())\nCreator: \(owner) \nSummary: \(title)\nGuests invited: \(attendees.count-1)"
            }else if timeSheet[indexPath.row].rows == 2{
                cell.textLabel?.text = "\(start.getTimeOfDate()) - \(end.getTimeOfDate()):\n(\(owner)) \(title) "
            }else{
                cell.textLabel?.text = "\(start.getTimeOfDate()) - \(end.getTimeOfDate()): (\(owner)) - \(title)"
            }
            
        }else{
            cell.backgroundColor = UIColor(red: 0/255, green: 255/255, blue: 146/255, alpha: 1.0) // Light green
            cell.textLabel?.text = "\(start.getTimeOfDate()) - \(end.getTimeOfDate())"
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        if timeSheet[indexPath.row].booked{
            if timeSheet[indexPath.row].owner == GoogleAPIManager.user{
                tableViewSchedule.deselectRowAtIndexPath(indexPath, animated: true)
                performSegueWithIdentifier("segueEvent", sender: timeSheet[indexPath.row])
            }else{
                tableViewSchedule.deselectRowAtIndexPath(indexPath, animated: true)
                GoogleAPIManager.showAlert("Error", message: "Room is booked! Contact \(timeSheet[indexPath.row].owner) if the booking should be cancelled", view: self)
            }
        }else{
            if selectedRows.count >= 1{
                if ScheduleManager.checkIfRowIsValid(selectedRows, selected: timeSheet[indexPath.row]){
                    selectedRows.append(timeSheet[indexPath.row])
                }else{
                    self.tableViewSchedule.deselectRowAtIndexPath(indexPath, animated: true)
                    GoogleAPIManager.showAlert("Error", message: "The selected is not valid. It should be in connection with other selections", view: self)
                }
            }else{
                
                selectedRows.append(timeSheet[indexPath.row])
            }
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath){
        let selected = timeSheet[indexPath.row]
        if selected == selectedRows.first || selected == selectedRows.last{
            selectedRows.removeAtIndex(selectedRows.indexOf(timeSheet[indexPath.row])!)
        }else{
            self.tableViewSchedule.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            GoogleAPIManager.showAlert("Error", message: "Selection is not valid.", view: self)
        }
    }
    
    func eventAlert(title:String, message:String, indexPath: NSIndexPath){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let deselect = UIAlertAction(title: "Deselect row", style: .Cancel){
                UIAlertAction in
                self.tableViewSchedule.deselectRowAtIndexPath(indexPath, animated: true)
        }
        let ok = UIAlertAction(title: "Continue", style: .Default, handler: nil)
        
        alert.addAction(deselect)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueNext"{
            if let destinationVC = segue.destinationViewController as? ScheduleVC{
                destinationVC.beaconObj = beaconObj
                destinationVC.date = date.nextDay()
            }
        }else if segue.identifier == "segueEvent"{
            if let destinationVC = segue.destinationViewController as? EventVC{
                let eventObj = sender as! Event
                destinationVC.eventObj = eventObj
                destinationVC.beaconObj = beaconObj
            }
        }
    }

}
