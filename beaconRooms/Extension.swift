//
//  Extension.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/30/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit

extension NSDateFormatter {
    convenience init(dateFormat: String){
        self.init()
        self.dateFormat = dateFormat
        self.timeZone = NSTimeZone.localTimeZone()
    }
}

extension NSDate{
    struct Formatter{
        static let withoutTime = NSDateFormatter(dateFormat: "dd-MM-yy")
        static let withTime = NSDateFormatter(dateFormat: "dd-MM-yy H:mm")
        static let onlyTime = NSDateFormatter(dateFormat: "H:mm")
        static let localTime = NSTimeZone.localTimeZone()
    }
    
    struct GetCalendar{
        static let calendar = NSCalendar.currentCalendar()
    }
    
    func customFormatted()-> String{
        return Formatter.withoutTime.stringFromDate(self)
    }
    
    func getTimeOfDate()->String{
        return Formatter.onlyTime.stringFromDate(self)
    }
    
    func getDateTime()->String{
        return Formatter.withTime.stringFromDate(self)
    }
    
    func nextDay()->NSDate{
        let dateComponent = NSDateComponents()
        dateComponent.day = 1
        return GetCalendar.calendar.dateByAddingComponents(dateComponent, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    func isBetween(start: NSDate, end: NSDate)->Bool{
        return (self.compare(start) == NSComparisonResult.OrderedDescending) &&
                (self.compare(end) == NSComparisonResult.OrderedAscending) ||
                (self == start)
    }
}

extension String {
    var asDate: NSDate? {
        return NSDate.Formatter.withTime.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
}