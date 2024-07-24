//
//  LocationProvider.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import Foundation
import SwiftUI
import CoreLocation

@Observable class LocationProvider:  NSObject, CLLocationManagerDelegate {
    
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
    
    func getTestLocations() -> [MapLocationMovement] {
        let loc1 = MapLocationMovement(coordinate: CLLocationCoordinate2D(latitude: 49.68085209853679, longitude: 8.616717557314166), time: Date())
        let loc2 = MapLocationMovement(coordinate: CLLocationCoordinate2D(latitude: 49.68108638931229, longitude: 8.619989695011895), time: Date())
        let loc3 = MapLocationMovement(coordinate: CLLocationCoordinate2D(latitude: 49.72624023185234, longitude: 8.442843393812112), time: Date())
        let result = [loc1, loc2, loc3]
        return result
    }
    
}
