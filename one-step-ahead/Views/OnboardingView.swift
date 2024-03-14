//
//  OnboardingView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to").font(.system(size: 35)).multilineTextAlignment(.center)
                Text("One Step Ahead!").font(.system(size: 35)).multilineTextAlignment(.center)
                Image("1sa")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20).padding()
//                Text("Welcome to One Step Ahead").padding()
                NavigationLink(destination: OverviewView()) {
                    Text("Continue")
                }
            }
            .padding()
            .onAppear {
                healthKitViewModel.checkAuthorizationStatus()
            }
        }
    }
}

struct OverviewView: View {
    var body: some View {
            VStack {
                Text("We’re dedicated to helping you live your best life by staying hydrated, active, and well rested!")
                    .multilineTextAlignment(.center)
                NavigationLink(destination: GetStartedView()) {
                    Text("Continue")
                }
            }
            .padding()
    }
}

struct GetStartedView: View {
    var body: some View {
            VStack {
                Text("To start out, tell us a little about yourself and what goals you hope to achieve!")
                    .multilineTextAlignment(.center)
                NavigationLink(destination: DataIntakeView()) {
                    Text("Continue")
                }
            }
            .padding()
    }
}



struct DataIntakeView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var calorieGoal = ""
    @State var sleepGoal = ""
    @State var hydrationGoal = ""
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var hkViewModel: HealthKitViewModel
    
    @State var completed = false
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
            }
            Section(header: Text("Goals")) {
                LabeledContent("Exercise Goal") {
                    TextField("\(hkViewModel.generateBaselineExerciseGoal()) Cal", text: $calorieGoal)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Sleep Goal") {
                    TextField("\(hkViewModel.generateBaselineSleepGoal()) hrs", text: $sleepGoal)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Hydration Goal") {
                    TextField("\(hkViewModel.generateBaselineWaterGoal()) oz", text: $hydrationGoal)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section {
                Button("Save") {
                    // Perform action with form data
                    print("First name: \(firstName)")
                    print("Last name: \(lastName)")
                    print("Calorie: \(calorieGoal)")
                    print("Sleep: \(sleepGoal)")
                    print("Hydration: \(hydrationGoal)")
                                        
                    completed = authHandler.setUserData(
                        first: firstName,
                        last: lastName,
                        water: Double(hydrationGoal) ?? hkViewModel.generateBaselineWaterGoal(),
                        sleep: Double(sleepGoal) ?? hkViewModel.generateBaselineSleepGoal(),
                        exercise: Double(calorieGoal) ?? hkViewModel.generateBaselineExerciseGoal()
                    )
                }
                NavigationLink(destination: OnboardingCompleteView()) {
                    Text("Continue")
                }.disabled(!completed)
                
            
            }
        }
    }
}

struct OnboardingCompleteView: View {
    // TODO: Remove back button after reaching main page
    @StateObject var authHandler: AuthViewModel = AuthViewModel()
    var body: some View {
        VStack {
            Text("You're all set, \(authHandler.user?.firstName ?? "User")!").font(.system(size: 30)).multilineTextAlignment(.center)
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            NavigationLink(destination: MainView()) {
                Text("Let's get started!").font(.system(size: 24))
            }
        }

    }

}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
