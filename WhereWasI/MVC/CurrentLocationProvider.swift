//
//  LocationProvider.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import Foundation
import SwiftUI
import CoreLocation

@Observable class CurrentLocationProvider:  NSObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    var currentUserLocation: CLLocation? = nil
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentUserLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()
        default:
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func getVisitedLocationFromStorage(daysToGoBack days: Int, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        PersistentLocationController.shared.getPastVisits(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyInMeter)
    }
    
    func getMovementLocationFromStorage(daysToGoBack days: Int, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        PersistentLocationController.shared.getPastMovements(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyInMeter)
    }
    
    func getAllLocationsStored(daysToGoBack days: Int, desiredAccuracyInMeter: CLLocationAccuracy) -> [MapLocation] {
        PersistentLocationController.shared.getAllPastLocations(daysToGoBack: days, desiredAccuracyOfLocations: desiredAccuracyInMeter)
    }
    
}
