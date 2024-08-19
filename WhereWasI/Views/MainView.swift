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
import OSLog

struct MainView: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    @State var bottomSheetPosition: BottomSheetPosition = .relative(BottomSheetPositioning.medium.rawValue)
    @State var showBottomSheet = true
    let logger = Logger()
    
    @AppStorage("locationsToShow") private var locationsToShow = ShowableLocations.all
    @AppStorage("showDaysBackSliderValue") private var timeSliderValue = 1.0
    @AppStorage("showDaysToGoBack") private var daysToGoBack = 1
    @AppStorage("desiredAccuracy") private var desiredAccuracyInMeter: CLLocationAccuracy = 250
    @AppStorage("lastUpdatedCountryList") private var lastUpdatedCountryList: Double = 0
    @AppStorage("showedTutorial") private var showedTutorial: Bool = false
    let timer = Timer.publish(every: 70, tolerance: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if !showedTutorial {
            TutorialView(tutorialFinished: $showedTutorial)
        } else {
            TabView {
                AllLocationsView(locationsToShow: $locationsToShow,daysToGoBack: $daysToGoBack, desiredAccuracy: $desiredAccuracyInMeter)
                    .environment(locationProvider)
                    .bottomSheet(bottomSheetPosition: self.$bottomSheetPosition, switchablePositions: [
                        .relative(BottomSheetPositioning.small.rawValue),
                        .relative(BottomSheetPositioning.medium.rawValue),
                        .relative(BottomSheetPositioning.large.rawValue)
                    ], headerContent: {headLineView}) {
                        //The list of the most popular songs of the artist.
                        VStack {
                            pickerLocationKind
                            timeSlider
                            accuracySlider

                            
                        }
                        .padding()
                        

                    }
                    .customAnimation(.snappy.speed(2))//(.easeIn.speed(3)) //.linear.speed(1.5))
                    .customBackground(.thickMaterial)
                    .tabItem {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Recent locations")
                    }
                AchievementsView(lastUpdatedCountryList: $lastUpdatedCountryList)
                    .environment(locationProvider)
                    .tabItem {
                        Image(systemName: "star")
                        Text("Achievements")
                    }
                EnableLocationTrackingView()
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
            }
            .onChange(of: timeSliderValue) {
                updateDaysToGoBack()
            }
            .onReceive(timer) { time in
                coordinatesToCountryCode()
            }
            .onAppear() {
                coordinatesToCountryCode()
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
    
    var timeSlider: some View {
        VStack {
            Slider(value: $timeSliderValue, in: 1...7, step: 1) {
                    Text("Show past \(Int(timeSliderValue))")

                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("7")
                }
            if(daysToGoBack <= 1) {
                Text("Last day is shown")
            } else {
                Text("Last \(daysToGoBack) days are shown")
            }
        }
    }
    
    var accuracySlider: some View {
        VStack {
            Slider(value: $desiredAccuracyInMeter, in: 10...15000, step: 1) {
                } minimumValueLabel: {
                    Text("10m")
                } maximumValueLabel: {
                    Text("15000m")
                }
                Text("Selected GPS Accuracy is \(desiredAccuracyInMeter) meters")
        }
    }
    
    var pickerLocationKind: some View {
        Picker("Points to look at", selection: $locationsToShow) {
            ForEach(ShowableLocations.allCases, id: \.self) { locationType in
                Text(locationType.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    private func updateDaysToGoBack() {
        daysToGoBack = Int(timeSliderValue)
    }
    
    @MainActor private func coordinatesToCountryCode() {
        let timeSinceLastCheck = abs(Date().timeIntervalSince1970 - lastUpdatedCountryList)
        if timeSinceLastCheck < 65 {
            return
        }
        //1.) Retrive locations
        guard var entitiesToCheck = PersistentLocationController.shared.fetchAllEntriesToCheck() else {return}
        //2.) Do checks
        if entitiesToCheck.count > 35 {
            entitiesToCheck = Array(entitiesToCheck.prefix(30))
        }
        var entitiesAlreadyChecked = [CheckLocationEntity]()
        for entity in entitiesToCheck {
            if let locationToCheck = entity.locationToCheck, let tempLocation = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: locationToCheck) {
                tempLocation.placemark { placemark, error in
                    guard let placemark = placemark else {
                        //logger.error(error?.localizedDescription)
                        return
                    }
                    if let countryCode = placemark.isoCountryCode {
                        PersistentLocationController.shared.addCountryCode(isoCountryCode: countryCode)
                    }
                }
            }
            entitiesAlreadyChecked.append(entity)
        }
        //3.) Delete checked
        PersistentLocationController.shared.deleteCheckEntities(checkEntities: entitiesAlreadyChecked)
        //4.) Set new lastCheckedDate
        lastUpdatedCountryList = Date().timeIntervalSince1970
    }
}

#Preview {
    MainView()
}
