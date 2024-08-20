//
//  EnableLocationTracking.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import SwiftUI

struct EnableLocationTrackingView: View {
    @Environment(CurrentLocationProvider.self) private var locationProvider
    
    var body: some View {
        VStack {
            switch locationProvider.authorizationStatus {
            case .authorizedAlways:
                Text("All is good")
            case .authorizedWhenInUse:
                Text("You only have activated location tracking if the app runs in the foreground. However, we need to access your location also in the background to detect your travel path. Please go to settings and change location access to always")
                Button("Open Settings") {
                    // Get the settings URL and open it
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }

            case .denied:
                Text("The access to access your location was denied. However we need the location to track your journeys. Please go to settings and change location access to always")
                Button("Open Settings") {
                    // Get the settings URL and open it
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }

            default:
                Text("No access to location of user")
            }
            VStack {
                Button("Make push notification") {
                    PushNotificationManager.sendMessage(delayFromNow: 1, title: "Test", subtitle: "succesfull")
                }
                Button("Push Notifications") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("Permission approved!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }.padding()
    }
}

#Preview {
    EnableLocationTrackingView()
}
