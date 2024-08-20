//
//  TutorialView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 19.08.24.
//

import SwiftUI
import CoreLocation

struct TutorialView: View {
    
    @Binding var tutorialFinished: Bool
    @ObservedObject var requestAuthorizationManager = RequestAuthorizationManager()
    @AppStorage("alreadyRequestedWhenInUseAuthorization") private var alreadyRequestedWhenInUseAuthorization: Bool = false
    @AppStorage("alreadyRequestedAlwaysAuthorization") private var alreadyRequestedAlwaysAuthorization: Bool = false
    
    var body: some View {
        let tutorialState = determineTutorialState(status: requestAuthorizationManager.locationStatus)
        switch tutorialState {
        case .start:
            requestWhenInUseAuthorizationView
        case .receivedWhenInUseAuthorization:
            requestAlwaysAuthorizationView
        case .allPermissionReceived:
            Button("All permissions received. You can now use the app") {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                        if success {
                            print("Permission approved!")
                        } else if let error = error {
                            print(error.localizedDescription)
                        }
                    }
                tutorialFinished = true
            }
        case .settingsRequired:
            EnableTrackingInSettingsView()
        }
    }
    
    var requestWhenInUseAuthorizationView: some View {
        VStack {
            if !alreadyRequestedWhenInUseAuthorization {
                Button("Please enable when in use authorizations to enable tracking your location while the app is opened") {
                    alreadyRequestedWhenInUseAuthorization = true
                    requestAuthorizationManager.requestWhenInUseAuthorization()
                }
            } else {
                EnableTrackingInSettingsView()
            }
        }
    }
    
    var requestAlwaysAuthorizationView: some View {
        VStack {
            if !alreadyRequestedAlwaysAuthorization {
                Button("Please enable when in use always authorisation to enable tracking your location while the app is running in the background to show you the location where you visited. The data is only saved on device") {
                    alreadyRequestedAlwaysAuthorization = true
                    requestAuthorizationManager.requestAlwaysAuthorization()
                }
            } else {
                EnableTrackingInSettingsView()
            }
        }
    }
    

    

    
    private func determineTutorialState(status: CLAuthorizationStatus?) -> TutorialState {
        guard let status = status else {
            return .start
        }
        if status == .notDetermined {
            return .start
        }
        if status == .authorizedWhenInUse {
            return .receivedWhenInUseAuthorization
        }
        if status == .authorizedAlways {
            return .allPermissionReceived
        }
        return .settingsRequired
    }
    
    private enum TutorialState {
        case start, receivedWhenInUseAuthorization, allPermissionReceived, settingsRequired
    }
}



