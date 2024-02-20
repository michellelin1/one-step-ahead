//
//  ExerciseReccomendation.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/19/24.
//
//import SwiftUI
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ExerciseReccView: ObservableObject {
    @Published var healthKitViewModel = HealthKitViewModel()
    @Published var userSession: FirebaseAuth.User?
    @Published var cal_remaining: Float = 350.0
    @Published var recommendedExercises: [Exercise] = []
    
    // Function to generate recommendations based on user preferences
    func generateRecommendations(for user: User?) {
        // can fix 350 to one recc by body mass
        let cal_remaining = Float(user?.exerciseGoal ?? 350.0) - Float(healthKitViewModel.caloriesBurned ?? 0.0)
        
        if cal_remaining < 50.0 {
            recommendedExercises = Exercise.dummyExercises.filter { $0.intensity == "Light" }
        }
        else if cal_remaining < 150.0 {
            recommendedExercises = Exercise.dummyExercises.filter { $0.intensity == "Moderate" }
        }
        else {
            recommendedExercises = Exercise.dummyExercises.filter { $0.intensity == "Heavy" }
        }
//        print(recommendedExercises)
//        return recommendedExercises
                // figure it
        // Logic to generate recommendations based on user data
        // For example, you might recommend exercises based on user's fitness level, goals, previous workouts, etc.
        // Here, we're just providing some dummy recommendations
//        recommendedExercises = Exercise.dummyExercises
    }
}

struct Exercise: Hashable {
    let name: String
    let difficulty: String // beg, int, adv
    let intensity: String // light, moderate, heavy
    
    // Dummy data for demonstration purposes
    static let dummyExercises: [Exercise] = [
        Exercise(name: "Push-ups", difficulty: "Intermediate", intensity: "Light"),
        Exercise(name: "Running", difficulty: "Beginner", intensity: "Heavy"), // 200 cal 20 mins
        Exercise(name: "Yoga", difficulty: "Beginner", intensity: "Moderate"), // 50-100 cal 15 mins
        Exercise(name: "Stretch", difficulty: "Beginner", intensity: "Light"), // 30-40 cal 10 mins
        Exercise(name: "Walk", difficulty: "Beginner", intensity: "Moderate"), // 200 cal 30 mins
        Exercise(name: "HIIT Workout", difficulty: "Intermediate", intensity: "Heavy"), // 200 cal 20 mins
        Exercise(name: "Weightlifting", difficulty: "Advanced", intensity: "Heavy"), // 200-300 60 mins
        Exercise(name: "Dancing", difficulty: "Intermediate", intensity: "Heavy") // 130-250 30 mins
        // Add more exercises as needed
    ]
}

