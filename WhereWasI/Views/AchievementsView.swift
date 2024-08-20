//
//  AchievementsView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 08.08.24.
//

import SwiftUI
import CoreLocation


struct AchievementsView: View {
    
    @State var testLocation1 = CLLocation(latitude: 52.1665716019436, longitude: 11.65793975891662)
    @State var countriesVisited = [Country]()// = PersistentLocationController.shared.retrieveAllVisitedCountries()
    //let persistenceController = PersistentLocationController.shared
    @Binding var lastUpdatedCountryList: Double
    
    var body: some View {
        VStack {
            Text("Already visited countries")
                .font(.title)
            List(countriesVisited) {
                Text("\($0.flag) \($0.countryName)")
            }
            .refreshable {
                coordinatesToCountryCode()
            }
        }
        .onChange(of: lastUpdatedCountryList) {
            countriesVisited = PersistentLocationController.shared.retrieveAllVisitedCountries()
            print("change Timer")
        }.onAppear() {
            countriesVisited = PersistentLocationController.shared.retrieveAllVisitedCountries()
        }
    }
    
    @MainActor private func coordinatesToCountryCode() {
        PushNotificationManager.sendMessage(delayFromNow: 5, title: "Debug", subtitle: "called coordinate to country")
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

//#Preview {
//    AchievementsView(visitedCountries: [Country(iso2CountryCode: "DE"),
//                                        Country(iso2CountryCode: "PE"),
//                                        Country(iso2CountryCode: "PA"),
//                                        Country(iso2CountryCode: "LC"),
//                                        Country(iso2CountryCode: "MF"),])
//}
