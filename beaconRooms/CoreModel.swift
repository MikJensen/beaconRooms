//
//  CoreModel.swift
//  beaconRooms
//
//  Created by Mik Jensen on 8/25/16.
//  Copyright © 2016 Mik Jensen. All rights reserved.
//

import UIKit
import CoreData

struct CoreModel {
    private static let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: Beacon CRUD
    
    static func saveBeacon(uuid: String, major: Int, minor: Int, name: String, booked: Bool)->Bool{
        let entityDescription = NSEntityDescription.entityForName("Beacon", inManagedObjectContext: managedObjectContext)
        let beacon = Beacon(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        beacon.setValue(uuid, forKey: "uuid")
        beacon.setValue(major, forKey: "major")
        beacon.setValue(minor, forKey: "minor")
        beacon.setValue(name, forKey: "name")
        beacon.setValue(booked, forKey: "booked")
        
        do{
            try managedObjectContext.save()
            managedObjectContext
            return true
            
        } catch let error as NSError{
            
            fatalError("Save error: \(error.localizedFailureReason!)")
        }
        return false
    }
    
    static func fetchBeaconRequest(major: Int, minor: Int)->[NSManagedObject]{
        let entityDescription = NSEntityDescription.entityForName("Beacon", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDescription
        let pred = NSPredicate(format: "(major = %@ AND minor = %@)", argumentArray:  [major, minor])
        request.predicate = pred
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
            return results
        }catch let error as NSError{
            fatalError("FetchRequest error: \(error.localizedFailureReason!)")
        }
        
    }
    
    static func fetchOneBeacon(major: Int, minor: Int)->NSManagedObject!{
        let results = fetchBeaconRequest(major, minor: minor)
        if results.count > 0{
            return results.first!
        }else{
            return nil
        }
    }
    
    static func fetchBeacons()->[NSManagedObject]!{
        let fetchRequest = NSFetchRequest(entityName: "Beacon")

        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
                return results as! [NSManagedObject]
        } catch let error as NSError {
            fatalError("Fetch error: \(error.localizedFailureReason!)")
        }
        return nil
    }
    
    static func updateBooked(major: Int, minor: Int, booked: Bool)->Bool{
        let results = fetchBeaconRequest(major, minor: minor)
        results.first?.setValue(booked, forKey: "booked")
        
        do{
            try managedObjectContext.save()
            return true
        }catch let error as NSError{
            fatalError("Did not get beacon to update: \(error.localizedFailureReason!)")
        }
        return false
    }

    
    static func deleteBeacon(object: NSManagedObject){
        managedObjectContext.deleteObject(object)
    }
    
    // MARK: Schedule CRUD
    
    static func fetchScheduleRequest(major: Int, minor: Int, date: NSDate)->[NSManagedObject]!{
        let beacon = fetchOneBeacon(major, minor: minor)
        
        let entityDescription = NSEntityDescription.entityForName("Schedule", inManagedObjectContext: managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDescription
        let pred = NSPredicate(format: "(beacon == %@)", beacon.objectID)
        request.predicate = pred
        
        do{
            let results = try managedObjectContext.executeFetchRequest(request) as! [NSManagedObject]
            var sortedResults = [NSManagedObject]()
            for result in results{
                let startDate = result.valueForKey("start") as! NSDate
                if startDate.customFormatted(startDate) == date.customFormatted(date){
                    sortedResults.append(result)
                }
            }
            return sortedResults
        }catch let error as NSError{
            fatalError("Did not get schedules from beacon: \(error.localizedFailureReason!)")
        }
        return nil
    }
    
    static func fetchSchedulePosts(major: Int, minor: Int, date:NSDate)->[NSDate]!{
        let results = fetchScheduleRequest(major, minor: minor, date: date)
        
        var datesArray = [NSDate]()
        for result in results{
            let resultDate = result.valueForKey("start") as! NSDate
            datesArray.append(resultDate)
        }
        return datesArray
    }
    
    static func fetchOnePost(major: Int, minor: Int, date:NSDate)->NSManagedObject!{
        let results = fetchScheduleRequest(major, minor: minor, date: date)
        
        for result in results{
            let startDate = result.valueForKey("start") as! NSDate
            if startDate == date{
                return result
            }
        }
        return nil
    }
    
    static func saveSchedulePost(major: Int, minor: Int, start:NSDate){
        let beacon = fetchOneBeacon(major, minor: minor)
        
        let entityDescription = NSEntityDescription.entityForName("Schedule", inManagedObjectContext: managedObjectContext)
        let schedule = Schedule(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        
        schedule.setValue(start, forKey: "start")
        
        let beaconschedule = beacon.mutableSetValueForKey("schedule")
        beaconschedule.addObject(schedule)
        
        do{
            try schedule.managedObjectContext!.save()
        }catch let error as NSError{
            fatalError("Did not create schedule to beacon: \(error.localizedFailureReason!)")
        }
    }
    static func deleteSchedulePost(major: Int, minor: Int, date:NSDate){
        managedObjectContext.deleteObject(fetchOnePost(major, minor: minor, date: date))
    }
}
