//
//  WeatherButton.swift
//  SwiftUI-Weather
//
//  Created by Dongtaes on 20.01.2024.
//

import SwiftUI

struct WeatherButton: View{
    
    var title: String
    var textColor: Color
    var backgroundcolor: Color
    
    var body: some View{
        Text(title)
            .frame(width: 280, height: 50)
            .background(backgroundcolor)
            .foregroundColor(textColor)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius(10)
    }
}

struct WeatherButton_Previews : PreviewProvider{
    static var previews : some View{
        WeatherButton(title: "Test Title", textColor: .white, backgroundcolor: .blue)
    }
}
