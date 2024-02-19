//
//  OnboardingView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to One Step Ahead")
                NavigationLink(destination: OverviewView()) {
                    Text("Continue")
                }
            }
            .padding()
        }
    }
}

struct OverviewView: View {
    var body: some View {
            VStack {
                Text("We’re dedicated to helping you live your best life by staying hydrated, active, and well rested")
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
                Text("To start out, tell us a little about yourself and what goals you hope to achieve")
                NavigationLink(destination: DataIntakeView()) {
                    Text("Continue")
                }
            }
            .padding()
    }
}

class UserData: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    // Singleton instance for global access
    static let shared = UserData()
    
    private init() {} // Prevent external initialization
}


struct DataIntakeView: View {
    @ObservedObject var userData = UserData.shared
//    @State var firstName: String = ""
//    @State var lastName: String = ""
    @State private var sex = 0
    @State var birthday: Date = Date()
    let options = ["Male", "Female", "Other"]
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("First name", text: $userData.firstName)
                TextField("Last name", text: $userData.lastName)
                Picker("Biological Sex", selection: $sex) {
                    ForEach(0..<options.count) { index in
                        Text(options[index]).tag(index)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            }

            Section {
                Button("Save") {
                    // Perform action with form data
                    print("First name: \(userData.firstName)")
                    print("Last name: \(userData.lastName)")
                    print("Sex: \(sex)")
                    print("Birthday: \(birthday)")
                    
                }
                NavigationLink(destination: OnboardingCompleteView()) {
                    Text("Continue")
                }
            }
        }
    }
}

struct OnboardingCompleteView: View {
    // TODO: Remove back button after reaching main page
    var body: some View {
        VStack {
            Text("You're all set!")
            NavigationLink(destination: MainView()) {
                Text("Let's get started")
            }
        }
    }
}

#Preview {
    WelcomeView()
}
