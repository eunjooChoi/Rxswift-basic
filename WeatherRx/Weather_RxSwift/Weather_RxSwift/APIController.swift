//
//  APIController.swift
//  Weather_RxSwift
//
//  Created by 최은주 on 6/18/24.
//

import Foundation
import RxSwift

class APIController {
    struct Weather: Decodable {
        let cityName: String
        let temp: Double
        let humidity: Int
        let icon: String
        
        static let empty = Weather(
            cityName: "Unknown",
            temp: -1000,
            humidity: 0,
            icon: iconNameToChar(icon: "e")
        )
    }
    
    static let shared = APIController()
    private let apiKey = Bundle.main.apiKey
    let baseURL = URL(string: "http://api.openweathermap.org/data/2.5")!
    
    private init() {}
    
    func currentWeather(city: String) -> Observable<Weather> {
        return buildRequest(pathComponent: "weather", params: [("q", city)])
            .map { data in
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                   let mainJson = json["main"] as? [String: Any],
                   let weatherJson = (json["weather"] as? [[String: Any]])?.first {
                    return Weather(cityName: json["name"] as? String ?? "Unknown",
                                   temp: mainJson["temp"] as? Double ?? -1000,
                                   humidity: mainJson["humidity"] as? Int ?? 0,
                                   icon: iconNameToChar(icon: weatherJson["icon"] as? String ?? "01d"))
                } else {
                    return Weather.empty
                }
            }
    }
    
    private func buildRequest(method: String = "GET", pathComponent: String, params: [(String, String)]) -> Observable<Data> {
        let url = baseURL.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        let keyQueryItem = URLQueryItem(name: "appid", value: apiKey)
        let unitsQueryItem = URLQueryItem(name: "units", value: "metric")
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if method == "GET" {
            var queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }
            queryItems.append(keyQueryItem)
            queryItems.append(unitsQueryItem)
            urlComponents.queryItems = queryItems
        } else {
            urlComponents.queryItems = [keyQueryItem, unitsQueryItem]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = jsonData
        }
        
        request.url = urlComponents.url!
        request.httpMethod = method
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        
        return session.rx.data(request: request)
    }
}

public func iconNameToChar(icon: String) -> String {
    switch icon {
    case "01d", "01n":
        return "☀️"
    case "02d", "02n":
        return "🌤️"
    case "03d", "03n":
        return "☁️"
    case "04d", "04n":
        return "☁️"
    case "09d", "09n":
        return "🌧️"
    case "10d", "10n":
        return "🌦️"
    case "11d", "11n":
        return "⚡️"
    case "13d", "13n":
        return "🌨️"
    case "50d", "50n":
        return "🌫️"
    default:
        return "E"
    }
}
