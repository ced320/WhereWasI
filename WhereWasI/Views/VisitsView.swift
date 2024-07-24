//
//  VisitsView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import SwiftUI
import MapKit

struct VisitsView: View {
    
    @Environment(LocationProvider.self) private var locationProvider
    
    var body: some View {
        Map() {
            UserAnnotation()
            ForEach (locationProvider.getTestLocations()) { location in
                Marker(location.time.description, coordinate: location.coordinate)
            }
            MapPolyline(coordinates: locationProvider.getTestLocations().map{$0.coordinate})
                .mapOverlayLevel(level: .aboveLabels)
                .stroke(Gradient(colors: [.black,.blue]), lineWidth: 4)
        }
    }
}

#Preview {
    VisitsView()
}
