//
//  Persistence.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import CoreData
import CoreLocation

struct PersistentLocationController {
    static let shared = PersistentLocationController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PastLocations")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func getPastVisits(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy) -> [MapLocation] {
        return getVisitLocationBetweenDates(startDateLongerAgo: NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(60*60*24*days)), endDateCloserToRightNow: NSDate(), desiredAccuracyInMeter: desiredAccuracyOfLocations)
    }
    
    func getPastMovements(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy) -> [MapLocation] {
        return getMovementLocationBetweenDates(startDateLongerAgo: NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(60*60*24*days)), endDateCloserToRightNow: NSDate(), desiredAccuracyInMeter: desiredAccuracyOfLocations)
    }
    
    func getAllPastLocations(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy) -> [MapLocation] {
        let visits = getPastVisits(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyOfLocations)
        let movements = getPastMovements(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyOfLocations)
        var visitPointer = 0
        var movementPointer = 0
        var allSortedPoints = [MapLocation]()
        while(visitPointer < visits.count || movementPointer < movements.count) {
            //Case 1 No visit points but movement Points left
            if  visitPointer >= visits.count{
                allSortedPoints += movements.suffix(movements.count - movementPointer)
                break
            }
            //Case 2 No movement points but visit points left
            else if movementPointer >= movements.count{
                allSortedPoints += visits.suffix(visits.count - visitPointer)
                break
            }
            //Case 3a Visit point is smaller than movement point
            else if visits[visitPointer].time <= movements[movementPointer].time {
                allSortedPoints.append(visits[visitPointer])
                visitPointer += 1
            }
            //Case 3b Movement point is smaller than visit point
            else {
                allSortedPoints.append(movements[movementPointer])
                movementPointer += 1
            }
        }
        return allSortedPoints
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()// managedObjectContext.save()
            //fetchMostRecentData()
        } catch let error as NSError {
            NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
        }
    }
    
    /// Gives back the movement locations as CLLocation sorted after descending date
    /// - Parameters:
    ///   - startDate: This date has to be further back in the past than the end Date
    ///   - endDate: This date has to be further to the present than the start date
    /// - Returns: locations as CLLocation where user was sorted by descending date
    private func getMovementLocationBetweenDates(startDateLongerAgo startDate: NSDate, endDateCloserToRightNow endDate: NSDate, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
        let fetchRequest = NSFetchRequest<MovementLocationEntity>(entityName: "MovementLocationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.container.viewContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var searchedLocations = [MapLocation]()
        if let locationData = frController.fetchedObjects {
            for locationDatum in locationData {
                if let locationDate = locationDatum.date, let locationDescription = locationDatum.summary, let locationDatum = locationDatum.movementLocation, let tempLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: locationDatum) {
                    let location = MapLocation(coordinate: tempLocation.coordinate, time: locationDate, locationType: .movement, hAccuracy: tempLocation.horizontalAccuracy, locationDescription: locationDescription)
                    searchedLocations.append(location)
                }
            }
        }
        return searchedLocations.filter{$0.hAccuracy < desiredAccuracyInMeter}
    }
    
    /// Gives back where the user visited sorted as CLVisit sorted by descending Date
    /// - Parameters:
    ///   - startDate: This date has to be further back in the past than the end Date
    ///   - endDate: This date has to be further to the present than the start date
    /// - Returns: visits as CLVisit sorted be descending date
    private func getVisitLocationBetweenDates(startDateLongerAgo startDate: NSDate, endDateCloserToRightNow endDate: NSDate, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
        let fetchRequest = NSFetchRequest<VisitedLocationEntity>(entityName: "VisitedLocationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.container.viewContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var searchedLocations = [MapLocation]()
        if let locationVisitData = frController.fetchedObjects {
            for locationDatum in locationVisitData {
                if let locationDate = locationDatum.date, let locationDescription = locationDatum.summary, let locationDatum = locationDatum.visitedLocation, let tempLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLVisit.self, from: locationDatum) {
                    let location = MapLocation(coordinate: tempLocation.coordinate, time: locationDate, locationType: .visit, hAccuracy: tempLocation.horizontalAccuracy, locationDescription: locationDescription, visitInfo: tempLocation)
                    if location.hAccuracy < desiredAccuracyInMeter {
                        searchedLocations.append(location)
                    }
                }
            }
        }
        return searchedLocations
    }
    
    private func addMovementLocationEntity(movementLocation location: CLLocation) {
        let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let date = location.timestamp
        let movementEntity = MovementLocationEntity(context: self.container.viewContext)
        movementEntity.date = date
        movementEntity.movementLocation = locationData
        saveData()
    }
    
    private func addVisitLocationEntity(visitLocation location: CLVisit) {
        let visitData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let date = location.arrivalDate
        let visitEntity = VisitedLocationEntity(context: self.container.viewContext)
        visitEntity.date = date
        visitEntity.visitedLocation = visitData
        saveData()
    }
}
