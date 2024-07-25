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
    
    var body: some View {
        Map() {
            UserAnnotation()
            ForEach (locationProvider.getAllLocationsStored(daysToGoBack: 7, desiredAccuracyInMeter: 500)) { location in
                Marker(location.time.description, coordinate: location.coordinate)
            }
            MapPolyline(coordinates: locationProvider.getAllLocationsStored(daysToGoBack: 7, desiredAccuracyInMeter: 500).map{$0.coordinate})
                .mapOverlayLevel(level: .aboveLabels)
                .stroke(Gradient(colors: [.black,.blue]), lineWidth: 4)
        }
    }}

#Preview {
    AllLocationsView()
}
