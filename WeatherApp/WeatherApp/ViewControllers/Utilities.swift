//
//  Utilities.swift
//  WeatherApp
//
//  Created by Tim Maher on 7/22/23.
//

import UIKit
import CoreLocation


// Generic Utility class
class Utilities: NSObject {

    // String Keys for serializing and deserializing the last known georgraphic position used to gather weather data by wrapping in a Dictionary
    private static let lastKnownWeatherCoordinateKey = "lastKnownWeatherCoordinateKey"
    private static let lastKnownLatSerializerKey = "lastKnownLatSerializerKey"
    private static let lastKnownLonSerializerKey = "lastKnownLonSerializerKey"
    
    // Write last known position to UserDefaults
    public static func setLastKnownLatLon(lat: Double, lon: Double) {
        
        let serializedDictionary = [lastKnownLatSerializerKey: lat, lastKnownLonSerializerKey: lon]
        UserDefaults.standard.setValue(serializedDictionary, forKey: lastKnownWeatherCoordinateKey)
    }
    
    // Return last known position from user defaults and wrap in CLLocationCoordinate2D
    public static func getLastKnownLatLon() -> CLLocationCoordinate2D? {
        let lastKnownLocation = UserDefaults.standard.object(forKey: lastKnownWeatherCoordinateKey) as? [String: Double]
        
        if let lastKnownLocation = lastKnownLocation {
            let lat = lastKnownLocation[lastKnownLatSerializerKey]
            let lon = lastKnownLocation[lastKnownLonSerializerKey]
            
            guard let lat = lat, let lon = lon else {
                return nil
            }
            
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
    
}
