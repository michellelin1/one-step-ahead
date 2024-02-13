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

struct DataIntakeView: View {
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State private var sex = 0
    @State var birthday: Date = Date()
    let options = ["Male", "Female", "Other"]
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
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
                    print("First name: \(firstName)")
                    print("Last name: \(lastName)")
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
