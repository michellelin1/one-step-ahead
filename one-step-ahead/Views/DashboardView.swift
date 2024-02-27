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
    @ObservedObject var exerciseRecc = ExerciseReccView()

    @StateObject var waterViewModel = WaterViewModel()
    @State var weather: ResponseBody?

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel

    var weatherManager = WeatherManager()

    let buttonColors: [Color] = [.green, .blue, .purple, .pink]
    
    
    var body: some View {
        NavigationView{
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Welcome back, \(authHandler.user?.firstName ?? "User")!")
                            .font(.system(size: 30))
                            .padding()
                    }
                    
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                            
                            NavigationLink(destination: ExerciseView()) {
                                buttonContent(imageName: "figure.walk.circle", text: "exercise activity", backgroundColor: buttonColors[0])
                            }
                            NavigationLink(destination: WaterView()) {
                                buttonContent(imageName: "drop.circle", text: "water intake", backgroundColor: buttonColors[1])
                            }
                            NavigationLink(destination: SleepView()) {
                                buttonContent(imageName: "moon.circle", text: "sleep patterns", backgroundColor: buttonColors[2])
                            }
                            NavigationLink(destination: HealthKitView()) {
                                buttonContent(imageName: "person.circle", text: "profile", backgroundColor: buttonColors[3])
                            }
                            .padding()
                        }
                        .padding()
                        .onAppear {
                            // figure out why first opening app doesnt generate anything
                            exerciseRecc.generateRecommendations(for: authHandler.user, healthKitViewModel: healthKitViewModel)
                        }
                        VStack(alignment: .leading) {
                            Text("Recommendations")
                                .font(.system(size: 30)).bold()
                                .padding()
                        }
                        
                        VStack {
                            Text("Please allow for best reccomendations")
                                .padding()
                        }
                        .multilineTextAlignment(.center)
                        
                        LocationButton(.shareCurrentLocation) {
                            locationManager.requestLocation()
                        }
                        .cornerRadius(30)
                        .symbolVariant(.fill)
                        .foregroundColor(.white)
                        
                        if let location = locationManager.location {
                            
    //                        Text("Your coordinate are:\(location.longitude), \(location.latitude)")
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
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Exercises")
                                    .font(.system(size: 24)).underline()
                                    .padding(.leading) // Add padding to align the text
                                Spacer()
                            }
                            Spacer()
                            ForEach(exerciseRecc.recommendedExercises, id: \.self) { exercise in
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .padding() // Add padding to align the text
                                }
    //                            .padding()
                                .background(Color.gray.opacity(0.2)) // Background color for the box
                                .cornerRadius(8) // Add corner radius for the box
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                    }
                    .navigationTitle("Dashboard")
                }
            }
    }
}

    

                    
private func buttonContent(imageName: String, text: String, backgroundColor: Color) -> some View {
    VStack {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .padding(.horizontal, 10)
            .foregroundColor(Color.white) // color of the icons
        
        Text(text)
            .foregroundColor(Color.white)
            .padding(.horizontal, 2)
    }
    .frame(width: 132, height: 150)
    .padding()
    .background(backgroundColor) // Customize the background color if needed
    .cornerRadius(10)
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
