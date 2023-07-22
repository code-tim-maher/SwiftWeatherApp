import Foundation

@available(iOS 15.0, *)
public struct WeatherService {

    private static let baseWeatherEndpointURL = "https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid=228ce847aa7b2c9bf9e08e60cb97de9c&units=imperial"
    private static let baseIconEndpointURL = "https://openweathermap.org/img/wn/{code}@2x.png"
    
    // Takes lat and lon as input and returns a weather response from the Weather API.
    // Throws Network Error if outside of acceptable status codes.
    // Caches data based on app "session", does not make REST request if cached data is present.
    public static func getWeather(lat: Double, lon: Double) async throws -> WeatherResponse? {
        
        var weatherEndpointURLString = baseWeatherEndpointURL.replacingOccurrences(of: "{lat}", with: String(lat))
        weatherEndpointURLString = weatherEndpointURLString.replacingOccurrences(of: "{lon}", with: String(lon))
        
        guard let url = URL(string: weatherEndpointURLString) else {
                return nil
            }
            
        if let cachedResponse = CacheUtility.shared.weatherCache.object(forKey: weatherEndpointURLString as NSString) {
            return cachedResponse
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            if !(200...299).contains(statusCode) {
                throw WeatherError.networkError
            }
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(WeatherResponse.self, from: data)
            CacheUtility.shared.weatherCache.setObject(decodedResponse, forKey: weatherEndpointURLString as NSString)
            return decodedResponse
            
        } catch {
            throw WeatherError.parsingError
        }
    }

    // Takes icon code as input and returns icon data from the Weather Icon API.
    // Throws Network Error if outside of acceptable status codes.
    // Caches data based on app "session", does not make REST request if cached data is present.
    public static func getWeatherIcon(code: String) async throws -> Data? {
        
        let weatherIconEndpointURLString = baseIconEndpointURL.replacingOccurrences(of: "{code}", with: code)
        
        guard let url = URL(string: weatherIconEndpointURLString) else {
                return nil
        }
        
        if let cachedImageData = CacheUtility.shared.imageCache.object(forKey: weatherIconEndpointURLString as NSString)  {
            return cachedImageData as Data
        }
            
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            
            if !(200...299).contains(statusCode) {
                throw WeatherError.networkError
            }
        }
        
        CacheUtility.shared.imageCache.setObject(data as NSData, forKey: weatherIconEndpointURLString as NSString)
        
        return data
    }
    
}
