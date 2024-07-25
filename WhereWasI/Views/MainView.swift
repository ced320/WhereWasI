//
//  MainView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import SwiftUI
import BottomSheet
import CoreLocation
import MapKit

struct MainView: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    @State var bottomSheetPosition: BottomSheetPosition = .relative(BottomSheetPositioning.medium.rawValue)
    @State var showBottomSheet = true
    
    var body: some View {
        AllLocationsView()
            .environment(locationProvider)
            .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                .relativeBottom(BottomSheetPositioning.small.rawValue),
                .relative(BottomSheetPositioning.medium.rawValue),
                .relativeTop(BottomSheetPositioning.large.rawValue)
            ], headerContent: {Text("Visits")}) {
                //The list of the most popular songs of the artist.
                ScrollView {
                    //SliderMinutesBack(percent: $intervallToShowOneToFourteen)
                    //PickLocationView(typeOfLocation: $typeOfLocation)
                    Text("Content")
                }
            }
            .customAnimation(.snappy.speed(2))//(.easeIn.speed(3)) //.linear.speed(1.5))
            .customBackground(.thickMaterial)
    }
}

#Preview {
    MainView()
}

public enum BottomSheetPositioning: CGFloat, CaseIterable {
    case small = 0.10//0.2246
    case medium = 0.5
    case large = 0.99
}
