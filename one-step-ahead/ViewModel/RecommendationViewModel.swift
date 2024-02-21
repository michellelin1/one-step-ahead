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
    @Published var sleepRecommendation: Double
    
    private var db = Firestore.firestore()
    
    init() {
        self.sleepRecommendation = -1
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
        // TODO
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
