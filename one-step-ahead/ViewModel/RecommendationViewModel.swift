//
//  ReccomendationViewModel.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/20/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class RecommendationViewModel: ObservableObject {
    @ObservedObject var hkViewModel = HealthKitViewModel()
    @Published var sleepRecommendation: Double = -1
    @Published var calorieRecommendation: Double = -1
    
    private var db = Firestore.firestore()
    private var user = User.empty
    
    
    init() {
        self.sleepRecommendation = -1
    }
    
    func setUser(_ user: User) {
        self.user = user
    }
    
    func getSleepRecommendation() -> Double {
        // TODO
        
        return 0
    }
    
    func calculateGradientSleepDeficit() -> Double {
        print("begin calculating sleep deficits")
        
        var pastSleepDeficits: [Double] = []
        
        // The previous 3 days of sleep history
        let pastSleepDurations: [PastSleepDuration] = hkViewModel.getPastSleepDurations()
        
        print("length of pastSleepDurations: \(pastSleepDurations.count)")
        
        for pastSleepDuration in pastSleepDurations {
            print("sleep date: \(pastSleepDuration.date)")
            print("sleep duration: \(pastSleepDuration.duration)")
            print()
            
            // Create date range for each day
            let calendar = Calendar.current
            let startOfCurrentDay = calendar.startOfDay(for: pastSleepDuration.date)
            let startOfPreviousDay = calendar.date(byAdding: .day, value: -1, to: startOfCurrentDay)!
            
            print("start of current day: \(startOfCurrentDay)")
            print("start of previous day: \(startOfPreviousDay)")
            
            Task {
                do {
                    // Fetch sleep goal for that day
                    let querySnapshot = try await db.collection("daily-sleep-goals")
                        .whereField("uid", isEqualTo: "uid")
                        .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfPreviousDay))
                        .whereField("date", isLessThan: Timestamp(date: startOfCurrentDay))
                        .getDocuments()
                    
                    for document in querySnapshot.documents {
                        print("\(document.documentID) => \(document.data())")
                    }
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            print("finish fetching past sleep goals")
            // Calculate sleep deficit for that day
        }
        
        return -12
    }
    
    func calculateGradientCaloricSurplus() -> Double {
        // Create date range for each day
        let today = Calendar.current.startOfDay(for: Date())
        Task {
            do {
                // Fetch sleep goal for that day
                let querySnapshot = try await db.collection("exercise")
                    .whereField("uid", isEqualTo: user.id ?? "failed")
                    .whereField("date", isLessThan: Timestamp(date: today))
                    .order(by: "date", descending: true)
                    .limit(to: 3)
                    .getDocuments()
                
                var exerciseHistory = try querySnapshot.documents.compactMap { document in
                    return try document.data(as: ExerciseGoal.self)
                }
                
                let surplus = exerciseHistory.map { exercise in
                    exercise.caloriesBurned - exercise.goal
                }
                print("calorie history \(exerciseHistory)")
                print("calorie surplus \(surplus)")
                
            } catch {
                print(error.localizedDescription)
            }
        }
        return 0
    }
    
    func calculateGradientWaterDeficit() -> Double {
        // TODO
        return 0
    }
    
    func fetchPastSleepGoals() -> [Double] {

        return []
    }
    
    
    
}
