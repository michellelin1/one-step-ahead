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
                    
                    HStack {
                            //TO DO: use icon provided by weatherAPI potentially
//                            VStack(spacing: 20) {
//                                Image(systemName: "cloud.rain.fill")
//                                    .font(.system(size: 40))
                                
                        Text(weather.current.condition.text).padding()
                        Text(weather.current.temp_f.roundDouble() + "°")
                                  .font(.system(size: 100))
                                  .fontWeight(.bold)
                        }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
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