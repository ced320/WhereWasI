//
//  MovementLocations.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import SwiftUI
import _MapKit_SwiftUI

struct MovementLocations: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    
    var body: some View {
        Map() {
            UserAnnotation()
            ForEach (locationProvider.getMovementLocationFromStorage(daysToGoBack: 7, desiredAccuracyInMeter: 500)) { location in
                Marker(location.time.description, coordinate: location.coordinate)
            }
            MapPolyline(coordinates: locationProvider.getMovementLocationFromStorage(daysToGoBack: 7, desiredAccuracyInMeter: 500).map{$0.coordinate})
                .mapOverlayLevel(level: .aboveLabels)
                .stroke(Gradient(colors: [.black,.blue]), lineWidth: 4)
        }
    }}

#Preview {
    MovementLocations()
}
