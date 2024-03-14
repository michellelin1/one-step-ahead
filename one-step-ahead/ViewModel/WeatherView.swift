//
//  WeatherView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/26/24.
//

import SwiftUI

struct WeatherView: View {
    var weather: ResponseBody
    @EnvironmentObject var recViewModel: RecommendationViewModel
    
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
                    
                VStack {
                    HStack {
                        Text(weather.current.condition.text).padding()
                        Text(weather.current.temp_f.roundDouble() + "°")
                                  .font(.system(size: 100))
                                  .fontWeight(.bold)
                        }
                    .frame(maxWidth: .infinity)
                    if (weather.current.temp_f > 65) {
                        Text("We've decreased your recommended exercise goal and increased your recommended water intake due to hot weather. Stay safe!")
                            .multilineTextAlignment(.center)
                    }
                    
                }
                    
                }
            }
            .padding()
//            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            .onAppear {
                        // Call the method to generate exercise recommendations
                        recViewModel.generateExerciseRecommendations(for: weather.current.temp_f)
                        recViewModel.getWaterRecommendation(for: weather.current.temp_f)
                    }
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
