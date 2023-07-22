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

    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var lowTempLabel: UILabel!
    @IBOutlet private weak var highTempLabel: UILabel!
    @IBOutlet private weak var windSpeedLabel: UILabel!
    @IBOutlet private weak var windBearingLabel: UILabel!
    @IBOutlet private weak var tempOverviewLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    
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
        highTempLabel.text = String(format: "High: %.1f°F", weatherResponse.main.temp_max)
        lowTempLabel.text = String(format: "Low: %.1f°F", weatherResponse.main.temp_min)
        windSpeedLabel.text = String(format: "Wind: %.1f MPH", weatherResponse.wind.speed)
        windBearingLabel.text = String(format: "Direction: %.1f°", weatherResponse.wind.deg)
        tempOverviewLabel.text = String(format: "Temp is: %.1f°F but feels like %.1f°F", weatherResponse.main.temp, weatherResponse.main.feels_like)
        humidityLabel.text = String(format: "Humidity is %.1f %%", weatherResponse.main.humidity)
    }
}
