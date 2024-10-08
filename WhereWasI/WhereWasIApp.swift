//
//  WhereWasIApp.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 24.07.24.
//

import SwiftUI

@main
struct WhereWasIApp: App {
    
    @State private var locationProvider = CurrentLocationProvider()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(locationProvider)
        }
    }
}
