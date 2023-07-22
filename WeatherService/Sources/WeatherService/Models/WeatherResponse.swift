//
//  WeatherResponse.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation

// Codable conforming struct to match response from weather service
// Weather Resposne is the "root" resposne
// All others structs in this file are "child/member" structs relating to the "root" struct
public class WeatherResponse: Codable {
    public var name: String
    public var weather: [IconWeather]
    public var main: MainWeather
    public var wind: WindWeather
    public var coord: CoordData
}

public class IconWeather: Codable {
    public var icon: String?
}

public class MainWeather: Codable {
    public var temp: Double
    public var feels_like: Double
    public var temp_min: Double
    public var temp_max: Double
    public var humidity: Double
}

public class WindWeather: Codable {
    public var speed: Double
    public var deg: Double
}

public class CoordData: Codable {
    public var lat: Double
    public var lon: Double
}
