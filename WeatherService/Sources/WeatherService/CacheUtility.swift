//
//  CacheUtility.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation


// A simple Struct as a singleton to easily map weather, various geocoding responses, and image icon data into a centralized cache.
// Each member cache has a maxItem count that is automatically configured. 
struct CacheUtility {
    
    public let weatherCache = NSCache<NSString, WeatherResponse>()
    public let geoCoderCityCache = NSCache<NSString, NSArray>()
    public let zipCoderCache = NSCache<NSString, ZipResponse>()
    public let imageCache = NSCache<NSString, NSData>()
    
    private let maxItems = 20
    
    static let shared = CacheUtility()
        
        private init() {
            weatherCache.countLimit = maxItems
            geoCoderCityCache.countLimit = maxItems
            zipCoderCache.countLimit = maxItems
            imageCache.countLimit = maxItems
        }
}




