//
//  MapLocationMovement.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import Foundation
import CoreLocation

struct MapLocationMovement: MapLocation {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let time: Date
}
