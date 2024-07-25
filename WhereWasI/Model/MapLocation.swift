//
//  MapLocationMovement.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import Foundation
import CoreLocation

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let time: Date
    let locationType: LocationType
    let hAccuracy: CLLocationAccuracy
    let locationDescription: String
    let visitInfo: CLVisit?
    
    init(coordinate: CLLocationCoordinate2D, time: Date, locationType: LocationType, hAccuracy: CLLocationAccuracy, locationDescription: String, visitInfo: CLVisit? = nil) {
        self.coordinate = coordinate
        self.time = time
        self.locationType = locationType
        self.hAccuracy = hAccuracy
        self.visitInfo = visitInfo
        self.locationDescription = locationDescription
    }
}



enum LocationType {
    case visit, movement
}
