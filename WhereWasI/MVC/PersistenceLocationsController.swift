//
//  Persistence.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import CoreData
import CoreLocation
import OSLog
import UserNotifications

@MainActor
class PersistentLocationController: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    
    static let shared = PersistentLocationController(type: .normal)
    static let preview = PersistentLocationController(type: .preview)
    static let testing = PersistentLocationController(type: .testing)
    
    @Published var savedVisitedLocations: [VisitLocationEntity] = []
    @Published var savedMovementLocations: [MovementLocationEntity] = []
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    private let fetchRequestVisitEntityController: NSFetchedResultsController<VisitLocationEntity>
    private let fetchRequestMovementEntityController: NSFetchedResultsController<MovementLocationEntity>
    private let logger = Logger()

    
    private init(type: PersistenceControllerType) {
        switch type {
        case .normal:
            let persistentStore = PersistentStoreData()
            self.managedObjectContext = persistentStore.context
        case .preview:
            let persistentStore = PersistentStoreData(inMemory: true)
            self.managedObjectContext = persistentStore.context
            // Add Mock Data
            try? self.managedObjectContext.save()
        case .testing:
            let persistentStore = PersistentStoreData(inMemory: true)
            self.managedObjectContext = persistentStore.context
        }
        //setup fetchRequestControllers
        //1.) For visitedLocations
        let frVisits = NSFetchRequest<VisitLocationEntity>(entityName: "VisitLocationEntity")
        frVisits.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequestVisitEntityController = NSFetchedResultsController(fetchRequest: frVisits,
                                                                       managedObjectContext: managedObjectContext,
                                                                       sectionNameKeyPath: nil,
                                                                       cacheName: nil)
        //2.) For MovementLocation
        let frMovements = NSFetchRequest<MovementLocationEntity>(entityName: "MovementLocationEntity")
        frMovements.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequestMovementEntityController = NSFetchedResultsController(fetchRequest: frMovements,
                                                                          managedObjectContext: managedObjectContext,
                                                                          sectionNameKeyPath: nil,
                                                                          cacheName: nil)
        super.init()
        fetchRequestVisitEntityController.delegate = self
        fetchRequestMovementEntityController.delegate = self
        
    }

    
    
    
    
    //----------
    
    func getPastVisits(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy, customVisits: [MapLocation]? = nil) -> [MapLocation] {
        if let customVisits = customVisits {
            return customVisits
        }
        return getVisitLocationBetweenDates(startDateLongerAgo: NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(60*60*24*days)), endDateCloserToRightNow: NSDate(), desiredAccuracyInMeter: desiredAccuracyOfLocations)
    }
    
    func getPastMovements(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy, customMovement: [MapLocation]? = nil) -> [MapLocation] {
        if let customMovement = customMovement {
            return customMovement
        }
        return getMovementLocationBetweenDates(startDateLongerAgo: NSDate(timeIntervalSince1970: Date().timeIntervalSince1970 - Double(60*60*24*days)), endDateCloserToRightNow: NSDate(), desiredAccuracyInMeter: desiredAccuracyOfLocations)
    }
    
    func getAllPastLocations(daysToGoBack days: Int, desiredAccuracyOfLocations: CLLocationAccuracy, customVisits: [MapLocation]? = nil, customMovement: [MapLocation]? = nil) -> [MapLocation] {
        let movements: [MapLocation]
        let visits: [MapLocation]
        if let customVisits = customVisits {
            visits = customVisits
        } else {
            visits = getPastVisits(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyOfLocations)
        }
        if let customMovement = customMovement {
            movements = customMovement
        } else {
            movements = getPastMovements(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyOfLocations)
        }
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
            else if visits[visitPointer].time >= movements[movementPointer].time {
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
    
    func addMovementLocationEntity(movementLocation location: CLLocation) {
        let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let date = location.timestamp
        let movementEntity = MovementLocationEntity(context: self.managedObjectContext)
        movementEntity.date = date
        movementEntity.movementLocation = locationData
        saveData()
    }
    
    func addVisitLocationEntity(visitLocation location: CLVisit) {
        let visitData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let date = location.arrivalDate
        let visitEntity = VisitLocationEntity(context: self.managedObjectContext)
        visitEntity.date = date
        visitEntity.visitedLocation = visitData
        saveData()
    }
    
    func addCheckLocationEntity(checkLocationToAdd location: CLLocation, description: String? = "Empty") {
        let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: true)
        let checkEntity = CheckLocationEntity(context: self.managedObjectContext)//MovementLocationEntity(context: self.container.viewContext)
        checkEntity.date = location.timestamp
        checkEntity.locationToCheck = locationData
        saveData()
    }
    
    func deleteCheckEntities(checkEntities entities: [CheckLocationEntity]) {
        let context = self.managedObjectContext
        // Delete the objects from the context
        for entity in entities {
            context.delete(entity)
        }
        saveData()
    }
    
    func addCountryCode(isoCountryCode countryCode: String) {
        if countryCode.count != 2 {
            return
        }
        let alreadyVisitedCountries = retrieveAllVisitedCountries2IsoCodes()
        if !alreadyVisitedCountries.contains(countryCode) {
            let visitedCountryEntity = VisitedCountryEntity(context: self.managedObjectContext)
            visitedCountryEntity.iso2CountryCode = countryCode
            saveData()
        }
    }
    
    func fetchAllEntriesToCheck() -> [CheckLocationEntity]? {
        // Create a fetch request for the specified entity
        let context = self.managedObjectContext
        let fetchRequest = NSFetchRequest<CheckLocationEntity>(entityName: "CheckLocationEntity")
        do {
            // Execute the fetch request and return the results
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            logger.error("Failed to fetch entries: \(error)")
            return nil
        }
    }
    
    private func retrieveAllVisitedCountries2IsoCodes() -> Set<String> {
        let fetchRequest = NSFetchRequest<VisitedCountryEntity>(entityName: "VisitedCountryEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "iso2CountryCode", ascending: false)]
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.managedObjectContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var result = Set<String>()
        if let fetchedCodes = frController.fetchedObjects {
            let countryCodesWithNil = fetchedCodes.map {$0.iso2CountryCode}
            for countryCode in countryCodesWithNil {
                if let countryCode = countryCode {
                    result.insert(countryCode)
                }
            }
            return result
        }
        return result
    }
    
    func retrieveAllVisitedCountries() -> [Country] {
        let fetchRequest = NSFetchRequest<VisitedCountryEntity>(entityName: "VisitedCountryEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "iso2CountryCode", ascending: false)]
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.managedObjectContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var result = [Country]()
        if let fetchedCodes = frController.fetchedObjects {
            let countryCodesWithNil = fetchedCodes.map {$0.iso2CountryCode}
            for countryCode in countryCodesWithNil {
                if let countryCode = countryCode {
                    result.append(Country(iso2CountryCode: countryCode))
                }
            }
            return result
        }
        return result
    }
    
    private func fetchMostRecentData() {
        //1.) For visitedLocations
        try? fetchRequestVisitEntityController.performFetch()
        if let newVisitedLocations = fetchRequestVisitEntityController.fetchedObjects {
            self.savedVisitedLocations = newVisitedLocations
        }
        //2.) For movementLocations
        try? fetchRequestMovementEntityController.performFetch()
        if let newMovementLocation = fetchRequestMovementEntityController.fetchedObjects {
            self.savedMovementLocations = newMovementLocation
        }
    }
    
    func saveData() {
        do {
            try managedObjectContext.save()
            fetchMostRecentData()
        } catch let error as NSError {
            NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
        }
    }
    
    
    /// Gives back the movement locations as CLLocation sorted after descending date
    /// - Parameters:
    ///   - startDate: This date has to be further back in the past than the end Date
    ///   - endDate: This date has to be further to the present than the start date
    /// - Returns: locations as CLLocation where user was sorted by descending date (newest date at position 0)
    private func getMovementLocationBetweenDates(startDateLongerAgo startDate: NSDate, endDateCloserToRightNow endDate: NSDate, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
        let fetchRequest = NSFetchRequest<MovementLocationEntity>(entityName: "MovementLocationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.managedObjectContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var searchedLocations = [MapLocation]()
        var lastAddedLocation: CLLocation? = nil
        if let locationData = frController.fetchedObjects {
            for locationDatum in locationData {
                if let locationDate = locationDatum.date, let locationDatum = locationDatum.movementLocation, let tempLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: locationDatum) {
                    let location = MapLocation(coordinate: tempLocation.coordinate, time: locationDate, locationType: .movement, hAccuracy: tempLocation.horizontalAccuracy, locationDescription: "locationDescription")
                    if lastAddedLocation == nil || (lastAddedLocation != nil && lastAddedLocation!.timestamp != tempLocation.timestamp) {
                        searchedLocations.append(location)
                        lastAddedLocation = tempLocation
                    }
                }
            }
        }
        let result = searchedLocations.filter{$0.hAccuracy < desiredAccuracyInMeter}
        return result
    }
    
    /// Gives back where the user visited sorted as CLVisit sorted by descending Date
    /// - Parameters:
    ///   - startDate: This date has to be further back in the past than the end Date
    ///   - endDate: This date has to be further to the present than the start date
    /// - Returns: visits as CLVisit sorted be descending date (newest date at position 0)
    private func getVisitLocationBetweenDates(startDateLongerAgo startDate: NSDate, endDateCloserToRightNow endDate: NSDate, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        let predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, endDate)
        let fetchRequest = NSFetchRequest<VisitLocationEntity>(entityName: "VisitLocationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.predicate = predicate
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.managedObjectContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        var searchedLocations = [MapLocation]()
        if let locationVisitData = frController.fetchedObjects {
            for locationDatum in locationVisitData {
                if let locationDate = locationDatum.date, let locationDatum = locationDatum.visitedLocation, let tempLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLVisit.self, from: locationDatum) {
                    let location = MapLocation(coordinate: tempLocation.coordinate, time: locationDate, locationType: .visit, hAccuracy: tempLocation.horizontalAccuracy, locationDescription: "locationDescription")
                    if location.hAccuracy < desiredAccuracyInMeter {
                        if let lastLocationAdded = searchedLocations.last {
                            if (lastLocationAdded.time.timeIntervalSince1970 - location.time.timeIntervalSince1970) < 0.1 {
                                if lastLocationAdded.hAccuracy > location.hAccuracy {
                                    //In case the current location has a better accuracy than the last one
                                    searchedLocations.removeLast()
                                    searchedLocations.append(location)
                                }
                            } else {
                                searchedLocations.append(location)
                            }
                        } else {
                            searchedLocations.append(location)
                        }
                        
                    }
                }
            }
        }
        return searchedLocations
    }
    
    /// Gives back the most recent movementLocation
    /// - Returns: the most recent movementLocation
    func getNewestMovementLocation() -> MovementLocationEntity? {
        let fetchRequest = NSFetchRequest<MovementLocationEntity>(entityName: "MovementLocationEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                      managedObjectContext: self.managedObjectContext,
                                                      sectionNameKeyPath: nil,
                                                      cacheName: nil)
        try? frController.performFetch()
        return frController.fetchedObjects?.first
    }
    
    private func makePushNotification(title: String, information: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = information
        content.sound = UNNotificationSound.default
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
}

//
//  PersistentStoreData.swift
//  TrackLowEnergy
//
//  Created by Cedric Thesis on 07.03.24.
//

struct PersistentStoreData {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PastLocations")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    var context: NSManagedObjectContext { container.viewContext }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
}


