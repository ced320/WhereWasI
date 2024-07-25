//
//  HeadlineView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 25.07.24.
//

import SwiftUI

struct HeadlineView: View {
    
    @Environment(CurrentLocationProvider.self) private var locationProvider
    
    var body: some View {
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
    HeadlineView()
}
