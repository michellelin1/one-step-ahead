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
    @Published var sleepRecommendation: Double = -1
    @Published var calorieRecommendation: Double = -1
    @Published var sleepHistory: [SleepDuration] = []
    @Published var exerciseHistory: [ExerciseGoal] = []
    @Published var waterHistory: [Water] = []
    
    private var db = Firestore.firestore()
    private var user = User.empty
    
    func setUser(_ user: User) {
        self.user = user
    }
    
    func getSleepRecommendation(){
        // TODO
        // get todays exercise amount
        Task {
            let sleepDeficit = await calculateGradientSleepDeficit()
            let exerciseSurplus = await calculateGradientCaloricSurplus()
            let currCal = await getCurrentCaloriesSurplus()
            
//            let extraFromSleepDeficit = sleepDeficit * 0.6
            
            let extraFromSleepDeficit = user.sleepGoal * sleepDeficit * 0.5
            print("user sleep goal: \(user.sleepGoal)")
            print("extra from sleep deficit: \(user.sleepGoal)")
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let extraFromExerciseSurplus = exerciseSurplus/200 * 0.2
            let extraFromCurrCal = currCal/200 * 0.3
            
            self.sleepRecommendation = user.sleepGoal + extraFromSleepDeficit + extraFromExerciseSurplus + extraFromCurrCal
            
            // update sleep goal in DB
            let todaySleepGoal = SleepDuration(sleepDuration: 0, goal: sleepRecommendation, date: Date(), uid: user.id ?? "")
            addToFirebase(collection: "sleep", obj: todaySleepGoal, date: Date())
        }
    }
    
    func getWaterRecommendation(){
        
    }
    
    func getCaloriesRecommendation(){
        Task {
            let sleepDeficit = await calculateGradientSleepDeficit()
            let exerciseSurplus = await calculateGradientCaloricSurplus()
            
            let minusFromSleepDeficit = user.exerciseGoal * sleepDeficit * 0.5
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let minusFromExerciseSurplus = exerciseSurplus/200 * 0.2
            // TODO: minusFromWaterDeficit
            
            self.calorieRecommendation = user.exerciseGoal - minusFromSleepDeficit - minusFromExerciseSurplus
            
            
            // TODO: Update calories goal in DB
//            let todaySleepGoal = SleepDuration(sleepDuration: 0, goal: sleepRecommendation, date: Date(), uid: user.id ?? "")
//            addToFirebase(collection: "sleep", obj: todaySleepGoal, date: Date())
        }
    }
    
    func calculateGradientSleepDeficit() async -> Double {
        print("begin calculating sleep deficits")
        let today = Calendar.current.startOfDay(for: Date())
        do {
            // Fetch sleep goal for that day
            let querySnapshot = try await db.collection("sleep")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: today))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let sleepHistory = try querySnapshot.documents.compactMap { document in
                return try document.data(as: SleepDuration.self)
            }
            
            let sleepDeficits = sleepHistory.map { sleep in
                if (sleep.sleepDuration >= sleep.goal) {
                    return 0.0
                }
                
                return (sleep.goal - sleep.sleepDuration) / sleep.goal
            }
            
            print("sleep history \(sleepHistory)")
            print("sleep deficit \(sleepDeficits)")
            print()
            self.sleepHistory = sleepHistory
            return calculateGradientRatio(fromRatios: sleepDeficits)
            
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func calculateGradientCaloricSurplus() async -> Double {
        // Create date range for each day
        let today = Calendar.current.startOfDay(for: Date())
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        do {
            // Fetch sleep goal for that day
            let querySnapshot = try await db.collection("exercise")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: nextDay))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let exerciseHistory = try querySnapshot.documents.compactMap { document in
                return try document.data(as: ExerciseGoal.self)
            }
            
            let surplus = exerciseHistory.map { exercise in
                let amt = exercise.caloriesBurned - exercise.goal
                return amt > 0 ? amt / exercise.goal : 0
            }
            print("calorie history \(exerciseHistory)")
            print("calorie surplus \(surplus)")
            self.exerciseHistory = exerciseHistory
            return calculateGradientRatio(fromRatios: surplus)
            
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func calculateGradientWaterDeficit() -> Double {
        // TODO
        return 0
    }
    
    func fetchPastSleepGoals() -> [Double] {

        return []
    }
    
    func getCurrentCaloriesSurplus() async -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        do {
            let querySnapshot = try await db.collection("exercise")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
                .whereField("date", isLessThan: Timestamp(date: nextDay))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            let cal = querySnapshot.documents.first.flatMap { document in
                try? document.data(as: ExerciseGoal.self)
            }
            let surplus = (cal?.caloriesBurned ?? 0) - (cal?.goal ?? 0)
            return surplus > 0 ? surplus : 0
        } catch {
            return 0
        }
    }
    
    func addToFirebase(collection: String, obj: Codable, date: Date) {
        print("adding \(collection) info to firebase")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        let docId = (self.user.id ?? "failed") + dateStr
        do {
            try self.db.collection(collection).document(docId).setData(from: obj)
        } catch {
            print("failed to add calories to firebase")
            print(error.localizedDescription)
        }
    }
    
    func calculateGradientRatio(fromRatios ratios: [Double]) -> Double {
        var gradientRatio: Double = 0
        var numDaysBeforeToday = 1
        for ratio in ratios {
            gradientRatio += pow(0.5, Double(numDaysBeforeToday)) * ratio
            
            print("numDaysBeforeToday: \(numDaysBeforeToday), gradientRatio: \(gradientRatio)")
            
            numDaysBeforeToday += 1
        }
        
        return gradientRatio
    }
    
}
