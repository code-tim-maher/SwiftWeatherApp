//
//  ZipResponse.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation

// Codable conforming struct to match response from zip geocoding service
public class ZipResponse: Codable {
    public var zip: String
    public var name: String
    public var lat: Double
    public var lon: Double
    public var country:String
}
