//
//  EnableTrackingInSettingsView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 19.08.24.
//

import SwiftUI

struct EnableTrackingInSettingsView: View {
    var body: some View {
        VStack {
            Text("Please enable always Location tracking in order for the app to work correctly. Without this permission we can not present you the the locations where you have been. Make sure to allow access to precise location as well")
            Button("Open Settings") {
                // Get the settings URL and open it
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

#Preview {
    EnableTrackingInSettingsView()
}
