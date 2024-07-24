//
//  MapLocation.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import Foundation
import CoreLocation

protocol MapLocation: Identifiable {
    var id: UUID { get }
    var coordinate: CLLocationCoordinate2D {get}
    var time: Date {get}
}
