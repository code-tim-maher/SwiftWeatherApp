//
//  CityResponse.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation

// Codable conforming struct to match response from city geocoding service
public class CityResponse: Codable {
    public var name: String
    public var lat: Double
    public var lon: Double
    public var country: String?
    public var state: String?
}

