//
//  AchievementController.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 08.08.24.
//

import Foundation
import MapKit
import Contacts

@Observable class AchievementController {
    
    //@AppStorage var lastUpdateDatum
    
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}

