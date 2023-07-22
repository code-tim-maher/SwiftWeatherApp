//
//  UIViewController+Extension.swift
//  WeatherApp
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation
import UIKit
import WeatherService

// Convinient extensions to use in any View Controller
extension UIViewController {
    
    // If there is an issue with weather APIs, pass error to easily show alert message.
    // If error is something else, generic message applies.
    func showWeatherError(error: Error) {
        var message = "Something unexpected happen, please try again"
        var title = "Unexpected Error"
        
        if let weatherError = error as? WeatherError {
            title = weatherError.getErrorAlertTitle()
            message = weatherError.getErrorAlertMessage()
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
