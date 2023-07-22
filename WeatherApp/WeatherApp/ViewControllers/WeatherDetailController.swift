//
//  WeatherDetailController.swift
//  WeatherApp
//
//  Created by Tim Maher on 7/22/23.
//

import UIKit
import WeatherService

// A simple readonly view controller that displays weather data about the selected location.
class WeatherDetailController: UIViewController {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var windBearingLabel: UILabel!
    
    
    private var weatherResponse: WeatherResponse
    
      // Initializer to pass required data to view controller and load from Xib
      init(weatherResponse: WeatherResponse) {
          self.weatherResponse = weatherResponse
          super.init(nibName: "WeatherDetailController", bundle: nil)
      }
      
      // This initializer is never used and does not need to be implemented
      required init?(coder aDecoder: NSCoder) {
          fatalError("coder not implemented")
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        loadIcon()
        
    }
    // Each weather response has at least one icon, this function serves to load the image and display it on the imageView
    private func loadIcon() {
        guard let iconCode = weatherResponse.weather.first?.icon else {
            return
        }
        
        // Gather image data and load it when ready
        Task {
            do {
                if let imageData = try await WeatherService.getWeatherIcon(code: iconCode) {
                    let image = UIImage(data: imageData)
                    iconImageView.image = image
                }
            } catch {
                showWeatherError(error: error)
            }
        }
    }
    
    // For data immediately available, format labels to show appropriate data
    private func setupLabels() {
        cityLabel.text = weatherResponse.name
        highTempLabel.text = String(format: "High: %.1f F", weatherResponse.main.temp_max)
        lowTempLabel.text = String(format: "Low: %.1f F", weatherResponse.main.temp_min)
        windSpeedLabel.text = String(format: "Wind: %.1f MPH", weatherResponse.wind.speed)
        windBearingLabel.text = String(format: "Direction: %.1f", weatherResponse.wind.deg)
    }
}
