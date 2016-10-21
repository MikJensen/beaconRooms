//
//  ScheduleManager.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/31/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import GoogleAPIClient

struct ScheduleManager{
    static var today:NSDate?
    
    static func getTimeSheet(date: NSDate, events: [GTLCalendarEvent])->[Event]{
        today = NSDate()
        return checkIfBooked(events, timeScheduleArr: createTimeSchedule(date), date: date)
    }

    private static func createTimeSchedule(date: NSDate)->[NSDate]{
        var timeSchedule = [NSDate]()
        let calendar = NSCalendar.currentCalendar()
        
        var start = "\(date.customFormatted()) 06:00".asDate!
        let end = "\(date.customFormatted()) 21:30".asDate!
        
        while start.timeIntervalSinceDate(end) <= 0.0{
            let newStart = calendar.dateByAddingUnit(.Minute, value: 30, toDate: start, options: [])!
            if newStart.compare(today!) == NSComparisonResult.OrderedDescending{
                timeSchedule.append(start)
            }
            start = newStart
        }
        return timeSchedule
    }
    
    private static func checkIfBooked(eventSchedule: [GTLCalendarEvent], timeScheduleArr: [NSDate], date:NSDate)->[Event]{
        var eventSheet = [Event]()
        var timeSchedule = timeScheduleArr
        let calendar = NSCalendar.currentCalendar()
        
        for e in eventSchedule{
            let startGTL : GTLDateTime! = e.start.dateTime
            let startDate = NSDateFormatter.localizedStringFromDate(startGTL.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle).asDate
            
            let endGTL : GTLDateTime! = e.end.dateTime
            let endDate = NSDateFormatter.localizedStringFromDate(endGTL.date, dateStyle: .ShortStyle, timeStyle: .ShortStyle).asDate
            
            let attendeesArr = e.attendees ?? []

            let minutes = NSCalendar.currentCalendar().components(.Minute, fromDate: startDate!, toDate: endDate!, options: []).minute ?? 0
            let result = minutes/30
            
            if startDate?.customFormatted() == date.customFormatted(){
                let eventObj = Event(summary: e.summary ?? "(No title)", start: startDate!, end: endDate!, booked: true, owner: e.creator.email, rows: result, eventId: e.identifier, attendees: attendeesArr)
                for i in 0..<result{
                    let time = calendar.dateByAddingUnit(.Minute, value: (i*30), toDate: eventObj.start, options: [])!
                    if let index = timeSchedule.indexOf(time){timeSchedule.removeAtIndex(index)}
                }
                
                eventSheet.append(eventObj)
            }
        }
        for t in timeSchedule{
            let newT = calendar.dateByAddingUnit(.Minute, value: 30, toDate: t, options: [])
            eventSheet.append(Event(summary: "", start: t, end: newT!, booked: false, owner: "", rows: 1, eventId: "", attendees: []))
        }

        eventSheet.sortInPlace({$0.start.compare($1.start) == NSComparisonResult.OrderedAscending})
        
        return eventSheet
    }

    static func checkIfRowIsValid(rows: [Event], selected: Event)->Bool{
        let calendar = NSCalendar.currentCalendar()
        
        let beforeFirst = calendar.dateByAddingUnit(.Minute, value: -30, toDate: rows.first!.start, options: [])
        if selected.start == beforeFirst{
            return true
        }else if selected.start == rows.last!.end{
            return true
        }else{
            return false
        }
    }
}
