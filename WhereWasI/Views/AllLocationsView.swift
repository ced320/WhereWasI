//
//  AllLocationsView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import SwiftUI
import MapKit

struct AllLocationsView: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    @Binding var locationsToShow: ShowableLocations
    @State private var locations = [MapLocation]()
    @State private var daysToGoBack = 7
    @State private var desiredAccuracy: CLLocationAccuracy = 500
    
    
    var body: some View {
        VStack {
            Map() {
                UserAnnotation()
                ForEach (locations) { location in
                    Marker(location.time.description, coordinate: location.coordinate)
                }
                MapPolyline(coordinates: (locations).map{$0.coordinate})
                    .mapOverlayLevel(level: .aboveLabels)
                    .stroke(Gradient(colors: [.black,.blue]), lineWidth: 4)
            }
            .onAppear() {
                calculateLocationsToShow()
            }
            .onChange(of: locationsToShow) {
                calculateLocationsToShow()
            }
        }
    }
    
    private func calculateLocationsToShow() {
        switch locationsToShow {
        case .movement:
            locations = locationProvider.getMovementLocationFromStorage(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
            print(locations.count)
            for location in locations {
                print(location)
            }
        case .visit:
            locations = locationProvider.getVisitedLocationFromStorage(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
        case .all:
            locations = locationProvider.getAllLocationsStored(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
        }
    }
}

