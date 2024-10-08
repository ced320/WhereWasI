//
//  VisitsView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import SwiftUI
import MapKit
import BottomSheet

struct VisitsView: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    
    var body: some View {
        Map() {
            UserAnnotation()
            ForEach (locationProvider.getVisitedLocationFromStorage(daysToGoBack: 7, desiredAccuracyInMeter: 500)) { location in
                Marker(location.time.description, coordinate: location.coordinate)
            }
            MapPolyline(coordinates: locationProvider.getVisitedLocationFromStorage(daysToGoBack: 7, desiredAccuracyInMeter: 500).map{$0.coordinate})
                .mapOverlayLevel(level: .aboveLabels)
                .stroke(Gradient(colors: [.black,.blue]), lineWidth: 4)
        }
    }
}

#Preview {
    VisitsView()
}


