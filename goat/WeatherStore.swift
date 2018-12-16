//
//  WeatherStore.swift
//  goat
//
//  Created by Chen Wu on 12/15/18.
//  Copyright © 2018 Chen Wu. All rights reserved.
//

import Foundation
import CoreLocation

enum RequestWeatherResponse {
    case success(WeatherResponse)
    case failure(Error?)
}

final class WeatherStore: NSObject {
    
    func requestWeather(location: CLLocation, completionHandler: @escaping (RequestWeatherResponse) -> Void) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let urlString = "https://api.darksky.net/forecast/2e8a5b5970d142cfa6c7c0ef36b4b317/\(latitude),\(longitude)"
        guard let url = URL(string: urlString) else {
            assertionFailure()
            dispatchToMainThread { completionHandler(.failure(nil)) }
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data) else {
                    dispatchToMainThread { completionHandler(.failure(nil)) }
                    return
            }
            dispatchToMainThread { completionHandler(.success(weatherResponse)) }
        }.resume()
    }
}


struct WeatherResponse: Codable {
    let dailyWeather: [DailyWeather]
    let timezone: String
    
    enum CodingKeys: String, CodingKey {
        case daily = "daily"
        case data = "data"
        case timezone = "timezone"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timezone = try container.decode(String.self, forKey: .timezone)
        let dailyDto = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .daily)
        self.dailyWeather = try dailyDto.decode([DailyWeather].self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {}
}
struct DailyWeather: Codable {
    let time: Double
    let icon: String
    let minTemp: Double
    let maxTemp: Double
    let summary: String
    
    enum CodingKeys: String, CodingKey {
        case daily = "daily"
        case data = "data"
        case time = "time"
        case icon = "icon"
        case minTemp = "temperatureMin"
        case maxTemp = "temperatureMax"
        case summary = "summary"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.time = try container.decode(Double.self, forKey: .time)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.minTemp = try container.decode(Double.self, forKey: .minTemp)
        self.maxTemp = try container.decode(Double.self, forKey: .maxTemp)
        self.summary = try container.decode(String.self, forKey: .summary)
    }
    
    func encode(to encoder: Encoder) throws {}
    
    var iconImageName: String {
        guard self.icon.contains("cloudy") else {
            return "other"
        }
        return "cloudy"
    }
}

func dispatchToMainThread(work: @escaping () -> Void) {
    DispatchQueue.main.async {
        work()
    }
}
