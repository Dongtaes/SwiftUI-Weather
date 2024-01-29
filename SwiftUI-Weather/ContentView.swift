//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Dongtaes on 15.01.2024.
//
/* TODO: Get realtime data and change accordingly
   TODO: Create enums for the weather symbols and can toggle between Fahrenheit and Celcius
   TODO: Add another cities
*/
import SwiftUI
import OpenMeteoSdk

struct ContentView: View {
    
    @State private var isNight = false
    @State private var weatherResponse: WeatherData?
    @State public var cityName: String = "Frankfurt"

    var body: some View {
        ZStack{
            BackgroundView(isNight: isNight)
            VStack{
                CityTextView(cityName: cityName,
                             date: getDay(weatherResponse: weatherResponse, index: 0))
                
                MainWeatherStatus(imageName: isNight ? ("moon.stars.fill") :
                                    "cloud.sun.fill",           
                                  temperature: Int(weatherResponse?.hourly.temperature2m[0] ?? 404))
                
                HStack(spacing: 22){
                    WeatherDayView(dayOfTheWeek: getDay(weatherResponse: weatherResponse, index: 1),
                                   imageName: "cloud.sun.fill",
                                   temperature: getAvgTemperature(weatherResponse: weatherResponse, index: 1))
                    WeatherDayView(dayOfTheWeek: getDay(weatherResponse: weatherResponse, index: 2),
                                   imageName: "cloud.fill",
                                   temperature: getAvgTemperature(weatherResponse: weatherResponse, index: 2))
                    WeatherDayView(dayOfTheWeek: getDay(weatherResponse: weatherResponse, index: 3),
                                   imageName: "cloud.drizzle.fill",
                                   temperature: getAvgTemperature(weatherResponse: weatherResponse, index: 3))
                    WeatherDayView(dayOfTheWeek: getDay(weatherResponse: weatherResponse, index: 4),
                                   imageName: "cloud.snow.fill",
                                   temperature: getAvgTemperature(weatherResponse: weatherResponse, index: 4))
                    WeatherDayView(dayOfTheWeek: getDay(weatherResponse: weatherResponse, index: 5),
                                   imageName: "cloud.sleet.fill",
                                   temperature: getAvgTemperature(weatherResponse: weatherResponse, index: 5))
                }
                Spacer()
                
                Button{
                    isNight.toggle()
                }label :{
                    WeatherButton(title: "Change Day Time", textColor: .blue, backgroundcolor: .white)
                }
                
                Spacer()
            }
        }.task{
            do{
                weatherResponse = try await abc(cityName: cityName)
                
            } catch {
                
            }
        }
    }
    func abc(cityName: String) async throws -> WeatherData{
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
    
    

}


#Preview {
    ContentView()
}

struct WeatherData {
    let hourly: Hourly
    let daily: Daily

    struct Hourly {
        let time: [Date]
        let temperature2m: [Float]
    }
    struct Daily {
        let time: [Date]
        let temperature2mMax: [Float]
        let temperature2mMin: [Float]
    }
}

struct WeatherDayView: View {
    
    var dayOfTheWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack{
            Text(dayOfTheWeek)
                .font(.system(size: 20, weight: .light))
                .foregroundColor(.white)
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 20, height: 20)
            
            Text("\(temperature)°")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct BackgroundView: View {
    
    var isNight : Bool
    var body: some View {
//        LinearGradient(gradient: Gradient(colors: [ isNight ? .black : .blue , isNight ? .gray : .lightBlue]),
//                       startPoint: .topLeading,
//                       endPoint: .bottomTrailing)
//        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        ContainerRelativeShape()
            .fill(isNight ? Color.black.gradient : Color.blue.gradient)
            .ignoresSafeArea()
        
    }
}

struct CityTextView : View{
    var cityName: String
    var date: String
    var body: some View{
        Text(cityName)
            .font(.system(size: 32,weight: .medium,design: .default))
            .foregroundColor(.white)
        Text(date)
            .font(.system(size: 22,weight: .medium,design: .default))
            .foregroundColor(.white)
    }
}

struct MainWeatherStatus: View{
    
    var imageName: String
    var temperature: Int
    
    var body: some View{
        VStack(spacing: 10){
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height:180)
            Text("\(temperature)°")
                .font(.system(size: 70, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
}


