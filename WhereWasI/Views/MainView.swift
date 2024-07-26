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
    
    @AppStorage("locationsToShow") private var locationsToShow = ShowableLocations.all
    //@State var alwaysLocationTrackingEnabled = false
    
    var body: some View {
        
        TabView {
            AllLocationsView(locationsToShow: $locationsToShow)
                .environment(locationProvider)
                .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                    .relative(BottomSheetPositioning.small.rawValue),
                    .relative(BottomSheetPositioning.medium.rawValue),
                    .relative(BottomSheetPositioning.large.rawValue)
                ], headerContent: {headLineView}) {
                    //The list of the most popular songs of the artist.
                    VStack {
                        Picker("Points to look at", selection: $locationsToShow) {
                            ForEach(ShowableLocations.allCases, id: \.self) { locationType in
                                Text(locationType.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        Text("Currently selected: \(locationsToShow.rawValue)")
                    }
                    

                }
                .customAnimation(.snappy.speed(2))//(.easeIn.speed(3)) //.linear.speed(1.5))
                .customBackground(.thickMaterial)
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Recent locations")
                }
            EnableLocationTrackingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
    
    var headLineView: some View {
        switch locationProvider.authorizationStatus {
        case .authorizedAlways:
            Text("Showing locations")
                .font(.title)
        case .authorizedWhenInUse:
            Text("Need always access to locations")
                .font(.title)
        default:
            Text("No access to location of user")
                .font(.title)
        }
    }
}

#Preview {
    MainView()
}
