//
//  EventVC.swift
//  beaconRooms
//
//  Created by Mik Jensen on 10/10/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

class EventVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var addGuestBtn: UIButton!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var summaryTF: UITextField!
    @IBOutlet weak var guestTF: UITextField!
    
    @IBOutlet weak var suggestContent: UIView!
    
    @IBOutlet weak var guestsTV: UITableView!
    @IBOutlet weak var suggestTV: UITableView!
    
    var eventObj:Event!
    var beaconObj:Beacon!
    
    var contacts = [String]()
    var suggests = [String]()
    var tempGuests = [AnyObject]()
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Event"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        guestTF.addTarget(self, action: #selector(EventVC.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        
        guestsTV.delegate = self
        guestsTV.dataSource = self
        suggestTV.delegate = self
        suggestTV.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        suggestContent.hidden = true
        super.viewWillAppear(animated)
        
        addGuestBtn.hidden = true
        
        deleteBtn.layer.cornerRadius = 4
        addGuestBtn.layer.cornerRadius = 4
        guestsTV.layer.cornerRadius = 4
        guestsTV.layer.borderWidth = 0.5
        guestsTV.layer.borderColor = UIColor(red:204.0/255.0, green:204.0/255.0, blue:204.0/255.0, alpha:1.0).CGColor
        
        if eventObj.booked{
            let summary = eventObj.summary
            if summary == "(No title)"{
                summaryTF.placeholder = summary
            }else{
                summaryTF.text = eventObj.summary
            }
            textLabel.text = "Edit event"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(buttonPressed))
            deleteBtn.hidden = false
        }else{
            textLabel.text = "Book \(beaconObj.title): \(eventObj.start.getTimeOfDate()) - \(eventObj.end.getTimeOfDate())"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(buttonPressed))
            deleteBtn.hidden = true
        }
        GoogleAPIManager.getContacts {
            (contacts) in
            self.contacts = contacts
        }
        tempGuests = eventObj.attendees
    }
    
    func dismissViewController(){
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidChange(textField: UITextField){
        if guestTF.text != ""{
            addGuestBtn.hidden = false
            getSuggests(guestTF.text!)
            if suggests.count == 0{
                suggestContent.hidden = true
            }else{
                suggestContent.hidden = false
            }
        }else{
            suggestContent.hidden = true
            addGuestBtn.hidden = true
        }
    }
    
    func getSuggests(text: String){
        suggests.removeAll()
        
        for i in contacts{
            if i.rangeOfString(text) != nil{
                suggests.append(i)
            }
        }
        suggests.sortInPlace()
        suggestTV.reloadData()
    }

    // MARK: - Button actions
    
    @IBAction func deletePressed(sender: AnyObject) {
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        GoogleAPIManager.deleteEvent(eventObj, vc: self, ch: {
            returnValue in
            if returnValue{
                self.dismissViewController()
            }
        })
        self.activityIndicator.stopAnimating()
    }
    @IBAction func buttonPressed(sender: AnyObject) {
        activityIndicator.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height/2)
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        if eventObj.booked{
            eventObj.attendees = tempGuests
            eventObj.summary = summaryTF.text
            GoogleAPIManager.updateEvent(self.eventObj, beaconObj: self.beaconObj, vc: self, ch: {
                returnValue in
                if returnValue{
                    self.dismissViewController()
                }
            })
        }else{
            GoogleAPIManager.createEvent(Event(summary: summaryTF.text!, start: eventObj.start, end: eventObj.end, booked: true, owner: "", rows: 0, eventId: "", attendees: tempGuests), beaconObj: self.beaconObj, vc: self, ch: {
                returnValue in
                if returnValue{
                    self.dismissViewController()
                }
            })
        }
        self.activityIndicator.stopAnimating()
    }
    @IBAction func addPressed(sender: AnyObject) {
        tempGuests.append(GoogleAPIManager.createAttendee(false, resource: false, email: guestTF.text!))
        guestTF.text = ""
        self.guestsTV.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if tableView == self.guestsTV{
            count = tempGuests.count
        }
        
        if tableView == self.suggestTV{
            count = suggests.count
        }
        return count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if tableView == self.guestsTV{
            cell = tableView.dequeueReusableCellWithIdentifier("guestCell") as UITableViewCell!
            let attendee = tempGuests[indexPath.row] as? GTLCalendarEventAttendee
            if attendee?.resource == true{
                cell?.textLabel!.text = attendee?.displayName
            }else{
                cell?.textLabel!.text = attendee?.email
            }
        }
        
        if tableView == self.suggestTV{
            cell = tableView.dequeueReusableCellWithIdentifier("suggestCell") as UITableViewCell!
            if suggests.count != 0{
                cell?.textLabel!.text = suggests[indexPath.row]
            }
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.suggestTV{
            guestTF.text = suggests[indexPath.row]
            suggestContent.hidden = true
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView == self.guestsTV{
            let attendee = tempGuests[indexPath.row] as? GTLCalendarEventAttendee
            if attendee?.organizer != true && attendee?.resource != true{
                return true
            }
        }
        return false
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var delete:UITableViewRowAction?
        if tableView == self.guestsTV{
            delete = UITableViewRowAction(style: .Default, title: "Delete") { action, index in
                self.tempGuests.removeAtIndex(indexPath.row)
                self.guestsTV.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        }
        return [delete!]
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {}

}
