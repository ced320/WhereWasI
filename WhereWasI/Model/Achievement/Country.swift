//
//  Country.swift
//  WhereWasI
//
//  Created by Cedric Frimmel-Hoffmann on 08.08.24.
//

import Foundation

struct Country: Identifiable {
    
    let id = UUID()
    let isoCode: String
    let countryName: String
    let flag: String
    
    init(iso2CountryCode: String) {
        self.isoCode = iso2CountryCode
        self.countryName = Locale.current.localizedString(forRegionCode: iso2CountryCode) ?? "No country"
        self.flag = Country.flag(country: iso2CountryCode)
    }
    
    private static func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}


