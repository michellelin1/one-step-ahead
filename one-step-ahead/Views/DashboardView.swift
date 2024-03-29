//
//  DashboardView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct DashboardView: View {

    @StateObject var waterViewModel = WaterViewModel()
    @State var weather: ResponseBody?

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    @EnvironmentObject var recViewModel: RecommendationViewModel
    @ObservedObject var exerciseRecc = ExerciseReccView()

    var weatherManager = WeatherManager()

    let buttonColors: [Color] = [.green, .blue, .purple, .pink]
    
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView {
                    WeeklyProgressView()
                    VStack(alignment: .leading) {
                        Text("Welcome back, \(authHandler.user?.firstName ?? "User")!")
                            .font(.system(size: 30))
                            .padding()
                    }
                    let cal_progress = Float(healthKitViewModel.caloriesBurned ?? 0.0) / Float(recViewModel.calorieRecommendation)
                    
                    let water_progress = Float(recViewModel.currWaterGoal.amountDrank) / Float(recViewModel.waterRecommendation)
                    
                    let sleepGoal = recViewModel.sleepHistory.count > 0 ? recViewModel.sleepHistory[0].goal : 1
                    let sleep_progress = Float(healthKitViewModel.sleepDuration / 3600 + (recViewModel.currSleepDuration.napTime ?? 0)) / Float(sleepGoal)
                    
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            
                            NavigationLink(destination: ExerciseView()) {
                                buttonContent(imageName: "figure.walk", text: "exercise activity", backgroundColor: buttonColors[0], progress: cal_progress)
                            }
                            NavigationLink(destination: WaterView()) {
                                buttonContent(imageName: "drop.fill", text: "water intake", backgroundColor: buttonColors[1], progress: water_progress)
                            }
                            NavigationLink(destination: SleepView()) {
                                buttonContent(imageName: "moon.zzz.fill", text: "sleep patterns", backgroundColor: buttonColors[2], progress: sleep_progress)
                            }
                            NavigationLink(destination: HealthKitView()) {
                                buttonContent(imageName: "person.circle", text: "profile", backgroundColor: buttonColors[3], progress: nil)
                            }
                            .padding()
                            .onAppear {
                                exerciseRecc.generateRecommendations(for: recViewModel.calorieRecommendation, healthKitViewModel: healthKitViewModel)
                            }
                        }
                        .padding()
                        VStack(alignment: .leading) {
                            Text("Weather")
                                .font(.system(size: 30)).bold()
                                .padding()
                        }
                        
                        if let location = locationManager.location {
                            if let weather = weather {
                                WeatherView(weather: weather)}
                            else {
                                LoadingView()
                                    .task {
                                        do {
                                            if let location = locationManager.location {
                                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                                            }
                                        } catch {
                                            print("Error getting weather:\(error)")
                                        }
                                    }
                            }
                        } else {
                            VStack {
                                Text("Please allow for best reccomendations")
//                                    .padding()
                            }
                            .multilineTextAlignment(.center)
                            
                            LocationButton(.shareCurrentLocation) {
                                locationManager.requestLocation()
                            }
                            .cornerRadius(30)
                            .symbolVariant(.fill)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        }
                        
                }
                .navigationTitle("Dashboard")
            }
        }
    }
}



                    
private func buttonContent(imageName: String, text: String, backgroundColor: Color, progress: Float?) -> some View {
    
    VStack {
//
//
        if let progress = progress {
            ProgressCircle(progress: progress, color: backgroundColor, imageName: imageName)
        }
        else {
            Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.horizontal, 10)
                        .foregroundColor(Color.pink) // color of the icons
        }
        Text(text)
            .foregroundColor(Color.primary)
            .padding(.horizontal, 2)
    }
    .frame(width: 132, height: 150)
    .padding()
    .background(Color.gray.opacity(0.10)) // Customize the background color if needed
    .cornerRadius(10)
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
