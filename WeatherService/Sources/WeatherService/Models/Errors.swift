//
//  Errors.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation

// Enum of errors one could encounter using the Weather and Geolocation services
// Also provides for easy incorporation into alert views. 
public enum WeatherError : Error {
    case networkError
    case parsingError
    
    public func getErrorAlertTitle() -> String {
        switch self {
        case .networkError:
            return "Network Error"
        case .parsingError:
            return "Parsing Error"
        }
    }
    
    public func getErrorAlertMessage() -> String {
        switch self {
        case .networkError:
            return "Please check your network connection and try again. There could be an issue with the remote service."
        case .parsingError:
            return "Your request was successful, but something is malformed in the response."
        }
    }
    
}
