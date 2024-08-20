//
//  E_CLLocation.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 20.08.24.
//

import Foundation
import CoreLocation

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}
