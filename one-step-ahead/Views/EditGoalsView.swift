//
//  EditGoalsView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 3/11/24.
//

import Foundation
import SwiftUI

struct EditGoalsView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var authHandler: AuthViewModel
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State private var sleepGoal = ""
    @State private var calorieGoal = ""
    @State private var hydrationGoal = ""
    @State var completed = false
    
    @State private var initialFirstName: String = ""
    @State private var initialLastName: String = ""
    @State private var initialSleepGoal: String = ""
    @State private var initialCalorieGoal: String = ""
    @State private var initialHydrationGoal: String = ""
    
    
    var body: some View {
        Form {
            Section(header: Text("User Information")) {
                TextField(initialFirstName, text: $firstName)
                TextField(initialLastName, text: $lastName)
            }
            Section(header: Text("Goals")) {
                LabeledContent("Sleep Goal") {
                    TextField(initialSleepGoal, text: $sleepGoal)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Exercise Goal") {
                    TextField(initialCalorieGoal, text: $calorieGoal)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Hydration Goal") {
                    TextField(initialHydrationGoal, text: $hydrationGoal)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
        
            Section {
                Button("Save") {
                    // Perform action with form data
                    
                    print("Sleep: \(sleepGoal)")
                    print("Exercise: \(calorieGoal)")
                    print("Water: \(hydrationGoal)")
                   
                    // check if the entry is empty, if it is set it to original goals, otherwise set to new
                    completed = authHandler.setUserData(
                        first: firstName.isEmpty ? initialFirstName : firstName,
                        last: lastName.isEmpty ? initialLastName : lastName,
                        water: hydrationGoal.isEmpty ? Double(initialHydrationGoal) ?? 48 : Double(hydrationGoal) ?? 48,
                        sleep: sleepGoal.isEmpty ? Double(initialSleepGoal) ?? 8 : Double(sleepGoal) ?? 8,
                        exercise: calorieGoal.isEmpty ? Double(initialCalorieGoal) ?? 350 : Double(calorieGoal) ?? 350
                    )
                    
                    self.isPresented = false
                }
            }
            .onAppear {
                // Store initial field values when the view appears
                initialFirstName = authHandler.user?.firstName ?? "User"
                initialLastName = authHandler.user?.lastName ?? "Name"
                initialSleepGoal = String(authHandler.user?.sleepGoal ?? 8)
                initialCalorieGoal = String(authHandler.user?.exerciseGoal ?? 350)
                initialHydrationGoal = String(authHandler.user?.waterGoal ?? 48)
            }
        }
        .navigationBarTitle("Edit Goals")
    }

}

//struct EditGoalsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditGoalsView(isPresented: true)
//    }
//}
