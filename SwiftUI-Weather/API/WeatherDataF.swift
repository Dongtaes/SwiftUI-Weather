//
//  WeatherDataF.swift
//  SwiftUI-Weather
//
//  Created by Dongtaes on 24.01.2024.
//
import OpenMeteoSdk
import Foundation


func WeatherFetch(cityName: String) async throws -> WeatherData{
    /// Make sure the URL contains `&format=flatbuffers`
    let url = URL(string: "https://api.open-meteo.com/v1/dwd-icon?latitude=50.1155,52.52&longitude=8.6842,13.41&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min&timezone=Europe%2FBerlin&format=flatbuffers")!
    let responses = try await WeatherApiResponse.fetch(url: url)

    /// Process first location. Add a for-loop for multiple locations or weather models
    var response = responses[0]
    switch cityName{
    case "Frankfurt":
        response = responses[0]
    case "Berlin":
        response = responses[1]
    default:
        response = responses[0]
    }
    
    

    /// Attributes for timezone and location
    let utcOffsetSeconds = response.utcOffsetSeconds
    let timezone = response.timezone
    let timezoneAbbreviation = response.timezoneAbbreviation
    let latitude = response.latitude
    let longitude = response.longitude

    let hourly = response.hourly!
    let daily = response.daily!

    

    /// Note: The order of weather variables in the URL query and the `at` indices below need to match!
    let data = WeatherData(
        hourly: .init(
            time: hourly.getDateTime(offset: utcOffsetSeconds),
            temperature2m: hourly.variables(at: 0)!.values
        ),
        daily: .init(
            time: daily.getDateTime(offset: utcOffsetSeconds),
            temperature2mMax: daily.variables(at: 0)!.values,
            temperature2mMin: daily.variables(at: 1)!.values
        )
    )

    /// Timezone `.gmt` is deliberately used.
    /// By adding `utcOffsetSeconds` before, local-time is inferred
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = .gmt
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
    dateFormatter.dateStyle = .full
    
    


    for (i, date) in data.hourly.time.enumerated() {
        print(dateFormatter.string(from: date))
        print(data.hourly.temperature2m[i])
    }
    for (i, date) in data.daily.time.enumerated() {
        print(date.formatted(Date.FormatStyle().weekday()))
        print(data.daily.temperature2mMax[i])
        print(data.daily.temperature2mMin[i])
    }

    return data

}
func getDay(weatherResponse: WeatherData?, index: Int) -> String{
    return weatherResponse?.daily.time[index]
        .formatted(Date.FormatStyle().weekday(.abbreviated))
        ?? "Error"
}
func getAvgTemperature(weatherResponse: WeatherData?, index: Int) -> Int{
    return Int(Float(weatherResponse?.daily.temperature2mMax[index] ?? 0) +
               Float(weatherResponse?.daily.temperature2mMin[index] ?? 0) ) / 2
}






