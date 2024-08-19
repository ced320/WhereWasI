//
//  PersistenceLocationsTest.swift
//  WhereWasITests
//
//  Created by Cedric Frimmel-Hoffmann on 07.08.24.
//

import XCTest
import CoreLocation
@testable import WhereWasI

final class PersistenceLocationsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testSortedOfLocations() {
        let currentDate = Date()
        //        let visit1 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .visit, hAccuracy: 0, locationDescription: "V2")
        //        let visit2 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .visit, hAccuracy: 0, locationDescription: "V1")
        //        let visit3 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .visit, hAccuracy: 0, locationDescription: "V3")
        let movements = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .movement, hAccuracy: 0, locationDescription: "1"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .movement, hAccuracy: 0, locationDescription: "2"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .movement, hAccuracy: 0, locationDescription: "3")]
                         
        let result = PersistentLocationController.shared.getPastMovements(daysToGoBack: 1, desiredAccuracyOfLocations: 1000,customMovement: movements)
        XCTAssert(result.count == 3)
        XCTAssertEqual(result[0].locationDescription, "1")
        XCTAssertEqual(result[1].locationDescription, "2")
        XCTAssertEqual(result[2].locationDescription, "3")
    }
    
    @MainActor func testSortedVisits() {
        let currentDate = Date()
        let visit1 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .visit, hAccuracy: 0, locationDescription: "V1")
        let visit2 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .visit, hAccuracy: 0, locationDescription: "V2")
        let visit3 = MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .visit, hAccuracy: 0, locationDescription: "V3")
        let visits = [visit1, visit2, visit3]

        let result = PersistentLocationController.shared.getPastVisits(daysToGoBack: 1, desiredAccuracyOfLocations: 1000, customVisits: visits)
        XCTAssert(result.count == 3)
        XCTAssertEqual(result[0].locationDescription, "V1")
        XCTAssertEqual(result[1].locationDescription, "V2")
        XCTAssertEqual(result[2].locationDescription, "V3")

    }
    
    @MainActor func testSortingVisitsAndMovements1() {
        let currentDate = Date()
        let movements = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .movement, hAccuracy: 0, locationDescription: "M1"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .movement, hAccuracy: 0, locationDescription: "M2"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 5), locationType: .movement, hAccuracy: 0, locationDescription: "M3")]
        let visits = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .visit, hAccuracy: 0, locationDescription: "V1"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 4), locationType: .visit, hAccuracy: 0, locationDescription: "V2"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 6), locationType: .visit, hAccuracy: 0, locationDescription: "V3")]
        
        let result = PersistentLocationController.shared.getAllPastLocations(daysToGoBack: 1, desiredAccuracyOfLocations: 1000, customVisits: visits, customMovement: movements)
        XCTAssert(result.count == 6)
        XCTAssertEqual(result[0].locationDescription, "M1")
        XCTAssertEqual(result[1].locationDescription, "V1")
        XCTAssertEqual(result[2].locationDescription, "M2")
        XCTAssertEqual(result[3].locationDescription, "V2")
        XCTAssertEqual(result[4].locationDescription, "M3")
        XCTAssertEqual(result[5].locationDescription, "V3")
    }
    
    @MainActor func testSortingVisitsAndMovements2() {
        let currentDate = Date()
        let movements = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .movement, hAccuracy: 0, locationDescription: "M1"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .movement, hAccuracy: 0, locationDescription: "M2"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .movement, hAccuracy: 0, locationDescription: "M3")]
        let visits = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 4), locationType: .visit, hAccuracy: 0, locationDescription: "V1"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 5), locationType: .visit, hAccuracy: 0, locationDescription: "V2"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 6), locationType: .visit, hAccuracy: 0, locationDescription: "V3")]
        
        let result = PersistentLocationController.shared.getAllPastLocations(daysToGoBack: 1, desiredAccuracyOfLocations: 1000, customVisits: visits, customMovement: movements)
        XCTAssert(result.count == 6)
        XCTAssertEqual(result[0].locationDescription, "M1")
        XCTAssertEqual(result[1].locationDescription, "M2")
        XCTAssertEqual(result[2].locationDescription, "M3")
        XCTAssertEqual(result[3].locationDescription, "V1")
        XCTAssertEqual(result[4].locationDescription, "V2")
        XCTAssertEqual(result[5].locationDescription, "V3")
    }
    
    @MainActor func testSortingVisitsAndMovements3() {
        let currentDate = Date()
        let movements = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .movement, hAccuracy: 0, locationDescription: "M1")]
        let visits = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .visit, hAccuracy: 0, locationDescription: "V1"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 4), locationType: .visit, hAccuracy: 0, locationDescription: "V2"),
                      MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 6), locationType: .visit, hAccuracy: 0, locationDescription: "V3")]
        
        let result = PersistentLocationController.shared.getAllPastLocations(daysToGoBack: 1, desiredAccuracyOfLocations: 1000, customVisits: visits, customMovement: movements)
        XCTAssert(result.count == 4)
        XCTAssertEqual(result[0].locationDescription, "M1")
        XCTAssertEqual(result[1].locationDescription, "V1")
        XCTAssertEqual(result[2].locationDescription, "V2")
        XCTAssertEqual(result[3].locationDescription, "V3")
    }
    
    @MainActor func testSortingVisitsAndMovements4() {
        let currentDate = Date()
        let movements = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.959190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 1), locationType: .movement, hAccuracy: 0, locationDescription: "M1"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.859190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 3), locationType: .movement, hAccuracy: 0, locationDescription: "M2"),
                         MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 5), locationType: .movement, hAccuracy: 0, locationDescription: "M3")]
        let visits = [MapLocation(coordinate: CLLocationCoordinate2D(latitude: 48.759190007218814, longitude: 40), time: Date(timeIntervalSince1970: currentDate.timeIntervalSince1970 - 2), locationType: .visit, hAccuracy: 0, locationDescription: "V1")]
        
        let result = PersistentLocationController.shared.getAllPastLocations(daysToGoBack: 1, desiredAccuracyOfLocations: 1000, customVisits: visits, customMovement: movements)
        XCTAssert(result.count == 4)
        XCTAssertEqual(result[0].locationDescription, "M1")
        XCTAssertEqual(result[1].locationDescription, "V1")
        XCTAssertEqual(result[2].locationDescription, "M2")
        XCTAssertEqual(result[3].locationDescription, "M3")
    }
    

}
