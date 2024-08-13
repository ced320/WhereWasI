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
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.locationManager.startMonitoringVisits()
        //self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if let lastAddedLocationDate = PersistentLocationController.shared.getNewestMovementLocation()?.date {
            if lastAddedLocationDate != location.timestamp {
                PersistentLocationController.shared.addMovementLocationEntity(movementLocation: location)
            } else {
                return
            }
        } else {
            PersistentLocationController.shared.addMovementLocationEntity(movementLocation: location)
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.makePushNotification(title: "Added visit", information: "")
        PersistentLocationController.shared.addVisitLocationEntity(visitLocation: visit)

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        switch status {
        case .notDetermined:
            break
        case .authorizedWhenInUse:
            print("Location access granted for 'When In Use'.")
        case .authorizedAlways:
            print("Location access granted for 'Always'.")
        case .restricted, .denied:
            print("Location access denied or restricted.")
        @unknown default:
            break
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
