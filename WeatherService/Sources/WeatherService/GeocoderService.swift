//
//  GeocoderService.swift
//  
//
//  Created by Tim Maher on 7/22/23.
//

import Foundation

@available(iOS 15.0, *)
public struct GeocoderService {

    private static let zipGeocoderURL = "https://api.openweathermap.org/geo/1.0/zip?zip={zip}&limit=10&appid=228ce847aa7b2c9bf9e08e60cb97de9c"
    private static let cityStateGeocoderURL = "https://api.openweathermap.org/geo/1.0/direct?q={query}&limit=10&appid=228ce847aa7b2c9bf9e08e60cb97de9c"
    
    // Takes zipcode as String input and returns a geocoded resposne from the Geocoder API.
    // Throws Network Error if outside of acceptable status codes.
    // Caches data based on app "session", does not make REST request if cached data is present.
    public static func geoCodeZip(zip: String) async throws -> ZipResponse? {
        
        let zipEndpointURLString = zipGeocoderURL.replacingOccurrences(of: "{zip}", with: zip)
        
        if let response = CacheUtility.shared.zipCoderCache.object(forKey: zipEndpointURLString as NSString) {
            return response
        }
        
        guard let url = URL(string: zipEndpointURLString) else {
                return nil
            }
            
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            if !(200...299).contains(statusCode) {
                throw WeatherError.networkError
            }
        }
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(ZipResponse.self, from: data)
        
        CacheUtility.shared.zipCoderCache.setObject(decodedResponse, forKey: zipEndpointURLString as NSString)
        
        return decodedResponse
    }
    
    // Takes city query as String input as well as predetermined query type and returns a geocoded resposne from the Geocoder API.
    // Throws Network Error if outside of acceptable status codes.
    // Caches data based on app "session", does not make REST request if cached data is present.
    public static func geoCodeCity(city: String, queryType: QueryType) async throws -> [CityResponse]? {
        
        guard var urlEncodedQuery = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        if queryType == .cityState {
            urlEncodedQuery = urlEncodedQuery.appending(",us")
        }
        let cityEndpointURLString = cityStateGeocoderURL.replacingOccurrences(of: "{query}", with: urlEncodedQuery)
        
        if let response = CacheUtility.shared.geoCoderCityCache.object(forKey: cityEndpointURLString as NSString) as? [CityResponse] {
            return response

        }
        
        guard let url = URL(string: cityEndpointURLString) else {
                return nil
            }
            
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            if !(200...299).contains(statusCode) {
                throw WeatherError.networkError
            }
        }
        
        let decoder = JSONDecoder()
        let decodedResponse =  try decoder.decode([CityResponse].self, from: data)
        CacheUtility.shared.geoCoderCityCache.setObject(decodedResponse as NSArray, forKey: cityEndpointURLString as NSString)

        return decodedResponse
    }
}
