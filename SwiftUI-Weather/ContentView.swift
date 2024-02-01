//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Dongtaes on 15.01.2024.
//
/* TODO: Create enums for the weather symbols and can toggle between Fahrenheit and Celcius
   TODO: Add another cities / implemented how to fetch the data for other cities, need to add toggling between cities
   TODO: Add other metrics like wind, maxTemp, minTemp, and clickable days.
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
                weatherResponse = try await WeatherFetch(cityName: cityName)
                
            } catch {
                
            }
        }
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
        .contentShape(Rectangle())
        .onTapGesture {
          print("The whole VStack is tappable now!")
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
        .contentShape(Rectangle())
        .onTapGesture {
          print("The whole VStack is tappable now!")
        }
    }
}


