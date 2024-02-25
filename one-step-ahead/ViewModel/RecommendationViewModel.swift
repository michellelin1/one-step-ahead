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
    @Published var waterRecommendation: Double = -1
    
    @Published var sleepHistory: [SleepDuration] = []
    @Published var exerciseHistory: [ExerciseGoal] = []
    @Published var waterHistory: [Water] = []
    
    @Published var currSleepDuration = SleepDuration.empty
    @Published var currExerciseGoal = ExerciseGoal.empty
    @Published var currWaterGoal = Water.empty
    
    private var db = Firestore.firestore()
    private var user = User.empty
    
    func setUser(_ user: User) {
        self.user = user
    }
    // ----------- RECOMMENDATION FUNCTIONS -------------
    func getSleepRecommendation(){
        // TODO
        // get todays exercise amount
        Task {
            let sleepDeficit = await calculateGradientSleepDeficit()
            let exerciseSurplus = await calculateGradientCaloricSurplus()
            let currCal = await getCurrentCaloriesSurplus()
            let waterDeficit = await calculateGradientWaterDeficit()
                        
            let extraFromSleepDeficit = user.sleepGoal * sleepDeficit * 0.5
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let extraFromExerciseSurplus = exerciseSurplus/200 * 0.2
            let extraFromCurrCal = currCal/200 * 0.3
            let extraFromWaterDeficit = user.waterGoal * waterDeficit * 0.1
            
            print("user sleep goal: \(user.sleepGoal)")
            print("extra from sleep deficit: \(extraFromSleepDeficit)")
            
            DispatchQueue.main.async {
                self.sleepRecommendation = self.user.sleepGoal + extraFromSleepDeficit + extraFromExerciseSurplus + extraFromCurrCal + extraFromWaterDeficit
            }
            // update sleep goal in DB
            let todaySleepGoal = SleepDuration(sleepDuration: 0, goal: sleepRecommendation, date: Date(), uid: user.id ?? "")
            addToFirebase(collection: "sleep", obj: todaySleepGoal, date: Date())
        }
    }
    
    func getWaterRecommendation(){
        Task {
            let sleepDeficit = await calculateGradientSleepDeficit()
            let exerciseSurplus = await calculateGradientCaloricSurplus()
            let currCal = await getCurrentCaloriesSurplus()
            
            let extraFromSleepDeficit = user.sleepGoal * sleepDeficit * 0.5
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let extraFromExerciseSurplus = exerciseSurplus/200 * 0.2
            let extraFromCurrCal = currCal/200 * 0.3
            
            print("user water goal: \(user.waterGoal)")
            print("extra from sleep deficit: \(extraFromSleepDeficit)")
            print("extra from exercise surplus: \(extraFromExerciseSurplus)")
            print("extra from curr call: \(extraFromCurrCal)")
            
            DispatchQueue.main.async {
                self.waterRecommendation = self.user.waterGoal + extraFromSleepDeficit + extraFromExerciseSurplus + extraFromCurrCal
            }
            // update sleep goal in DB
            updateGoalInFirebase(collection: "water", newGoal: self.waterRecommendation, date: Date())
        }
    }
    
    func getCaloriesRecommendation(){
        Task {
            let sleepDeficit = await calculateGradientSleepDeficit()
            let exerciseSurplus = await calculateGradientCaloricSurplus()
            let waterDeficit = await calculateGradientWaterDeficit()
            
            
            let minusFromSleepDeficit = user.exerciseGoal * sleepDeficit * 0.5
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let minusFromExerciseSurplus = exerciseSurplus/200 * 0.2
            let minusFromWaterDeficit = user.waterGoal * waterDeficit * 0.1
            
            print("user exercise goal: \(user.exerciseGoal)")
            DispatchQueue.main.async {
                self.calorieRecommendation = self.user.exerciseGoal - minusFromSleepDeficit - minusFromExerciseSurplus - minusFromWaterDeficit
            }
            
            // Update calories goal in DB
            updateGoalInFirebase(collection: "exercise", newGoal: self.calorieRecommendation, date: Date())
        }
    }
    
    // ------------ GETTER FUNCTIONS -------------
    func getExerciseHistory() {
        Task {
            await fetchExerciseHistory()
        }
    }
    
    func getCurrentCaloriesBurned() {
        Task {
            await fetchCurrentExerciseLog()
        }
    }
    
    
    // ----------- HELPER FUNCTIONS ---------------
    func calculateGradientSleepDeficit() async -> Double {
        print("begin calculating sleep deficits")
        // Fetch sleep goal for that day
        if (self.sleepHistory.count == 0) {
            await fetchSleepHistory()
        }
        
        let sleepDeficits = sleepHistory.map { sleep in
            if (sleep.sleepDuration >= sleep.goal) {
                return 0.0
            }
            return (sleep.goal - sleep.sleepDuration) / sleep.goal
        }
        return calculateGradientRatio(fromRatios: sleepDeficits)
            
    }
    
    private func fetchSleepHistory() async {
        let today = Calendar.current.startOfDay(for: Date())
        do {
            let querySnapshot = try await db.collection("sleep")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: today))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let sleepHistory = try querySnapshot.documents.compactMap { document in
                return try document.data(as: SleepDuration.self)
            }
            DispatchQueue.main.async {
                self.sleepHistory = sleepHistory
            }
        } catch {
            print("fetch sleep error")
            print(error.localizedDescription)
        }
    }
    
    func calculateGradientCaloricSurplus() async -> Double {
        print("begin calculating calories burned surplus")
        // Create date range for each day
        
        if (self.exerciseHistory.count == 0) {
            await self.fetchExerciseHistory()
        }
        
        let surplus = exerciseHistory.map { exercise in
            let amt = exercise.caloriesBurned - exercise.goal
            return amt > 0 ? amt / exercise.goal : 0
        }
        
        return calculateGradientRatio(fromRatios: surplus)
    }
    
    func calculateGradientWaterDeficit() async -> Double {
        // TODO
        print("begin calculating gradient water deficit")
        if (self.waterHistory.count == 0) {
            await fetchWaterHistory()
        }
        
        let waterDeficits = self.waterHistory.map { water in
            if (water.amountDrank >= water.goal) {
                return 0.0
            }
            
            return Double((water.goal - water.amountDrank) / water.goal)
        }

        return calculateGradientRatio(fromRatios: waterDeficits)
            
    }
    
    private func fetchWaterHistory() async {
        let today = Calendar.current.startOfDay(for: Date())
        do {
            let querySnapshot = try await db.collection("water")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: today))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let waterHist = try querySnapshot.documents.compactMap { document in
                return try document.data(as: Water.self)
            }
            
            DispatchQueue.main.async {
                self.waterHistory = waterHist
            }
        } catch {
            print("error fetching water history")
            print(error.localizedDescription)
        }
    }
    
    
    func getCurrentCaloriesSurplus() async -> Double {
        let currentExerciseLog = await self.fetchCurrentExerciseLog()
        let surplus = (currentExerciseLog?.caloriesBurned ?? 0) - (currentExerciseLog?.goal ?? 0)
        return surplus > 0 ? surplus : 0
    }
    
    func fetchCurrentExerciseLog() async -> ExerciseGoal? {
        print("fetching current exercise log")
        
        let today = Calendar.current.startOfDay(for: Date())
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        do {
            let querySnapshot = try await db.collection("exercise")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
                .whereField("date", isLessThan: Timestamp(date: nextDay))
                .order(by: "date", descending: true)
                .limit(to: 1)
                .getDocuments()
            let cal = querySnapshot.documents.first.flatMap { document in
                try? document.data(as: ExerciseGoal.self)
            }
            
            DispatchQueue.main.async {
                print("current calories burned: \(cal?.caloriesBurned ?? 0)")
                self.currExerciseGoal = cal ?? ExerciseGoal.empty
            }
            
            return cal
            
        } catch {
            print("Error fetching current exercise log")
            return nil
        }
    }
    
    private func fetchExerciseHistory() async {
        let today = Calendar.current.startOfDay(for: Date())
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        do {
            // Fetch exercise goals and logs for previous 3 days
            let querySnapshot = try await db.collection("exercise")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: nextDay))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let exerciseHistory = try querySnapshot.documents.compactMap { document in
                return try document.data(as: ExerciseGoal.self)
            }
            
            DispatchQueue.main.async {
                self.exerciseHistory = exerciseHistory
            }
        } catch {
            
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
    
    func updateGoalInFirebase(collection: String, newGoal: Double, date: Date) {
        print("updating \(collection) info to firebase")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        let docId = (self.user.id ?? "failed") + dateStr
        
        let doc = self.db.collection(collection).document(docId)
        let fieldToUpdate = "goal"
        doc.updateData([fieldToUpdate: newGoal])
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
