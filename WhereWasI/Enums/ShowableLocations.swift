//
//  ShowableLocations.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 26.07.24.
//

import Foundation

enum ShowableLocations: String, CaseIterable {
    case movement = "Movement"
    case visit = "Visits"
    case all = "All"
}

public enum BottomSheetPositioning: CGFloat, CaseIterable {
    case small = 0.20//0.2246
    case medium = 0.5
    case large = 0.99
}

public enum StorageType {
    case persistent, inMemory
}
