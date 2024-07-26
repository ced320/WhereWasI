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
    @Binding var daysToGoBack: Int
    @Binding var desiredAccuracy: CLLocationAccuracy 
    @State private var locations = [MapLocation]()
    
    
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
            .onChange(of: daysToGoBack) {
                calculateLocationsToShow()
            }
            .onChange(of: desiredAccuracy) {
                calculateLocationsToShow()
            }
        }
    }
    
    private func calculateLocationsToShow() {
        switch locationsToShow {
        case .movement:
            locations = locationProvider.getMovementLocationFromStorage(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
        case .visit:
            locations = locationProvider.getVisitedLocationFromStorage(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
        case .all:
            locations = locationProvider.getAllLocationsStored(daysToGoBack: daysToGoBack, desiredAccuracyInMeter: desiredAccuracy)
        }
    }
}

