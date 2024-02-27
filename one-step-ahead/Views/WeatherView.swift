//
//  WeatherView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/26/24.
//

import SwiftUI

struct WeatherView: View {
    var weather: ResponseBody
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.location.name)
                        .bold().font(.title)
                    
                    Text("Today \(Date().formatted(.dateTime.month().day().hour().minute()))")
                        .fontWeight(.light)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            
//                            VStack(spacing: 20) {
//                                Image(systemName: "cloud.rain.fill")
//                                    .font(.system(size: 40))
                                
                                Text(weather.current.condition.text)
                            }
                            .frame(width: 150, alignment: .leading)
                            
                            Spacer()
                            
                            Text(weather.current.temp_f.roundDouble() + "°")
                                      .font(.system(size: 100))
                                      .fontWeight(.bold)
                                      .padding()
                        }
                        
                        Spacer()
                            .frame(height: 250)
                    
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(width: .infinity, alignment: .leading)
            
            
            
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather Now")
                        .bold().padding(.bottom)
                    
//                    HStack{
//                        WeatherRow(logo: "thermometer", name: "Min temp", value: (weather.main.tempMin.roundDouble() + "°"))
//                        Spacer()
//                        WeatherRow(logo: "thermometer", name: "Max temp", value: (weather.main.tempMax.roundDouble() + "°"))
//                    }
                    HStack{
                        WeatherRow(logo: "wind", name: "Wind Speed", value: (weather.current.wind_mph.roundDouble() + "m/s"))
                        Spacer()
                        WeatherRow(logo: "humidity", name: "Humidity", value: (String(weather.current.humidity) + "%"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}

extension Double {
    func roundDouble() -> String {
        return String(format: "%.0f", self)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(weather: previewWeather)
    }
}
