//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Tim Maher on 7/22/23.
//

import UIKit
import CoreLocation
import WeatherService
import CoreLocationUI

class SearchViewController: UIViewController {

    @IBOutlet private weak var currentLocationButton: CLLocationButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var dataSource: [Any] = []
    private let geocoderCellIdentifier = "GeocoderCell"
    private let searchMinCharacterCount = 3
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignDelegates()
        setupViews()
        launchLastKnownLocationIfPossible()
    }

    // If the last known position (useed to gather weather data) has been recorded, use that data at app launch to view updated weather data.
    private func launchLastKnownLocationIfPossible() {
        if let coordinate = Utilities.getLastKnownLatLon() {
            Task {
                    let weatherResposne = await getWeather(lat: coordinate.latitude, lon: coordinate.longitude)
                    routeToWeatherDetails(resposne: weatherResposne)
            }
        }
    }
    
    // Helper method to isolate code assigning multiple delegates to self
    private func assignDelegates() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        locationManager.delegate = self
    }
    
    // Helper method to setup extra UI properties / register tableView Cells when screen has loaded
    private func setupViews() {
        let commonCornerRadius = 5.0
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: geocoderCellIdentifier)
        tableView.layer.cornerRadius = commonCornerRadius
        searchBar.layer.cornerRadius = commonCornerRadius
        searchBar.accessibilityIdentifier = "searchBar"
    }
    
    // CLLocationButton (Button to request user position) has been tapped
    @IBAction func currentLocationTapped(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    // Method to return geocoder response data based on American zipcode
    private func geoCodeForZip(zipString: String) async -> [ZipResponse]? {
        do {
            guard let zipResponse = try await GeocoderService.geoCodeZip(zip: zipString) else {
                return nil
            }
            
            return [zipResponse]
        } catch {
            showWeatherError(error: error)
        }
        return nil
    }
    
    // Method to gather geocoder response from geocoder services based on city/state text or "freeform" text.
    private func geoCodeForCity(cityString: String, queryType: QueryType) async -> [CityResponse]? {
        do {
            guard let cityResponse = try await GeocoderService.geoCodeCity(city: cityString, queryType: queryType) else {
                return nil
            }
            
            return cityResponse
        } catch {
            showWeatherError(error: error)
        }
        return nil
    }
    
    // Method to gather a weather resposne from weather services based on a geographic position
    private func getWeather(lat: Double, lon: Double) async -> WeatherResponse? {
        do {
            guard let weatherResponse = try await WeatherService.getWeather(lat: lat, lon: lon) else {
                return nil
            }
            return weatherResponse
        } catch {
            showWeatherError(error: error)
        }
        return nil
    }
    
    // Method to update suggestions based on feedback from Geocoder services
    private func refreshSuggestions(data: [Any]?) {
        
        guard let data = data else {
            return
        }
        
        dataSource = data
        tableView.reloadData()
    }
    
    // Routes the user to the weather details screen based on a valid weather response
    // Also records last known position used to gather weather data. 
    private func routeToWeatherDetails(resposne: WeatherResponse?) {
        
        guard let response = resposne else {
            return
        }
        
        let weatherDetailsController = WeatherDetailController(weatherResponse: response)
        present(weatherDetailsController, animated: true)
        Utilities.setLastKnownLatLon(lat: response.coord.lat, lon: response.coord.lon)
    }
}

// MARK: - CLLocation Manager Extension
extension SearchViewController: CLLocationManagerDelegate {
    
    // If the user has allowed location access, to conserve battery and overall privacy, disable collection after the first position is noted.
    // Then, use the location data to get weather data to route the user to the weather details screen.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lastLocation = locations.last
        let coordinate = lastLocation?.coordinate
        locationManager.stopUpdatingLocation()
        
        guard let coordinate = coordinate else {
            return
        }
        Task {
            let weatherResponse = await getWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            routeToWeatherDetails(resposne: weatherResponse)
        }
        
    }

    // Handle errors, typically this is denied permissions and can be treated without further action
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}

// MARK: - TableviewDelegate / DataSource Extension
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Since our data source can be either zip code or city resposnes, we need to check the underlying datasource type.
    // Then, we can display helpful suggestions to the user.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: geocoderCellIdentifier) else {
            return UITableViewCell()
        }
        
        let result = dataSource[indexPath.row]
        
        if let result = result as? ZipResponse {
            cell.textLabel?.text = result.name
        }
        
        if let result = result as? CityResponse {
            
            if let state = result.state {
                cell.textLabel?.text = "\(result.name), \(state)"

            } else {
                cell.textLabel?.text = "\(result.name)"
            }
        }
        
        cell.accessibilityIdentifier = String(format: "tableRow_%d", indexPath.row)
        return cell
    }
    
    // Since our data source can be either zip code or city resposnes, we need to check the underlying datasource type.
    // Then, we can gather the weather data and route the user to the details screen.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = dataSource[indexPath.row]
        
        var lat = 0.0
        var lon = 0.0
        
        if let result = result as? ZipResponse {
            lat = result.lat
            lon = result.lon
        }
        
        if let result = result as? CityResponse {
            lat = result.lat
            lon = result.lon
        }
        Task {
            let weatherResponse = await getWeather(lat: lat, lon: lon)
            routeToWeatherDetails(resposne: weatherResponse)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
}

// MARK: - UISearchBarDelegate Extension
extension SearchViewController: UISearchBarDelegate {
    
    // When search bar is tapped, validate the input as either zip, city/state, or freeform text.
    // Then, gather the geocoded response to gather the weather resposne.
    // Finally, route the user to the weather details screen.
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            var weatherResponse: WeatherResponse?
            let searchText = searchBar.text ?? ""
            let queryType = GeocoderUtilities.queryType(_forString: searchText)

            if queryType == .unknown || queryType == .cityState {
                let cityResponse = await geoCodeForCity(cityString: searchText, queryType: queryType)
                guard let firstCity = cityResponse?.first else {
                    return
                }
                
                weatherResponse = await getWeather(lat: firstCity.lat, lon: firstCity.lon)

            } else if queryType == .zip {
                let zipResponse = await geoCodeForZip(zipString: searchText)
                
                if let firstZip = zipResponse?.first {
                    weatherResponse = await getWeather(lat: firstZip.lat, lon: firstZip.lon)
                }
                
            }
            routeToWeatherDetails(resposne: weatherResponse)
        }
    }
    
    
    // When user input changes, check to see if it could be a city/state or zip and provide suggestions to the tableView.
    // If it's over the minimum characters in lenght then provide "freeform text" suggestions.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let queryType = GeocoderUtilities.queryType(_forString: searchText)
        
        switch queryType {
        case .zip:
            Task{
                let zipResponse = await geoCodeForZip(zipString: searchText)
                refreshSuggestions(data: zipResponse)
            }
        case .cityState:
            Task {
                let cityResponse = await geoCodeForCity(cityString: searchText, queryType: queryType)
                refreshSuggestions(data: cityResponse)
            }
        case .unknown:
            if searchText.count >= searchMinCharacterCount {
                Task {
                    let cityResponse = await geoCodeForCity(cityString: searchText, queryType: queryType)
                    refreshSuggestions(data: cityResponse)
                }
            }
        }
    }
}
