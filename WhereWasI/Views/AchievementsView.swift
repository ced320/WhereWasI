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
        }
        .onChange(of: lastUpdatedCountryList) {
            countriesVisited = PersistentLocationController.shared.retrieveAllVisitedCountries()
            print("change Timer")
        }.onAppear() {
            countriesVisited = PersistentLocationController.shared.retrieveAllVisitedCountries()
        }
    }
    

    

}

//#Preview {
//    AchievementsView(visitedCountries: [Country(iso2CountryCode: "DE"),
//                                        Country(iso2CountryCode: "PE"),
//                                        Country(iso2CountryCode: "PA"),
//                                        Country(iso2CountryCode: "LC"),
//                                        Country(iso2CountryCode: "MF"),])
//}
