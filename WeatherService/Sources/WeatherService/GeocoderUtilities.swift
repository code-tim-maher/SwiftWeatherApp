//
//  GeocoderUtilities.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//


import Foundation

// There are three different ways to request geocode data from the geocoder service.
// - Zip (requires different path in URL)
// - City,State (requires adding country code to query params for correct data)
// - Freeform Text (raw string query)
public enum QueryType {
    case zip
    case cityState
    case unknown
}

// A class to assist with easier use of the Geocoder service
public class GeocoderUtilities: NSObject {

    // REgular expressions to match zip and city,state inputs
    private static let zipRegex = #"^\d{5}$"#
    private static let cityStateRegex = #"^[A-Za-z\s]+,\s[a-zA-Z]{2}$"#

    // Detects search query type (zip,city/state, or freeform)
    public static func queryType(_forString query: String) -> QueryType {
        if stringMatchesRegex(stringInput: query, pattern: zipRegex) {
            return .zip
        } else if stringMatchesRegex(stringInput: query, pattern: cityStateRegex) {
            return .cityState
        }
        
        return .unknown
    }
    
    // Helper function to perform Regex comparisons
    private static func stringMatchesRegex(stringInput: String, pattern: String ) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        
        let range = NSRange(stringInput.startIndex..., in: stringInput)
        return regex.firstMatch(in: stringInput, options: [], range: range) != nil
    }
    
}
