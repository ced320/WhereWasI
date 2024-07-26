//
//  SelectLocationView.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 26.07.24.
//

import Foundation

import SwiftUI

struct PickLocationView: View {
    
    @Binding var typeOfLocation: ShowableLocations
    
    var body: some View {
        Picker("Points to look at", selection: $typeOfLocation) {
            ForEach(ShowableLocations.allCases, id: \.self) { locationType in
                Text(locationType.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
}
