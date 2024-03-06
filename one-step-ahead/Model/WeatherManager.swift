//
//  WeatherManager.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/21/24.
//

import Foundation
import CoreLocation

class WeatherManager {
    let locationManager = CLLocationManager()
    func getCurrentWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async throws -> ResponseBody{
        let API = "https://api.weatherapi.com/v1/current.json?key=1d12abb9201144b8adf51934242102&q="
        guard let url = URL(string: "\(API)\(latitude),\(longitude)")
        else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error fetching weather data")}

        let decodedData = try JSONDecoder().decode(ResponseBody.self, from: data)
        return decodedData
    }
}

struct ResponseBody: Decodable {
    var location: LocationResponse
    var current: CurrentResponse
}

struct LocationResponse: Decodable {
    var name: String
    var region: String
    var country: String
    var lat: Double
    var lon: Double
    var tz_id: String
    var localtime_epoch: Int
    var localtime: String
    }

struct CurrentResponse: Decodable {
    let last_updated_epoch: Int
    let last_updated: String
    let temp_c: Double
    let temp_f: Double
    let is_day: Int
    let condition: Condition
    let wind_mph: Double
    let wind_kph: Double
    let wind_degree: Int
    let wind_dir: String
    let pressure_mb: Double
    let pressure_in: Double
    let precip_mm: Double
    let precip_in: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
    let feelslike_f: Double
    let uv: Double
    let gust_mph: Double
    let gust_kph: Double
}

struct Condition: Decodable {
    let text: String
    let icon: String
    let code: Int
}

var previewWeather: ResponseBody = load("weatherData.json")
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

    
