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
    @Published var currCaloriesBurned: Double = 0
    
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
            let waterDeficit = await calculateGradientWaterDeficit()
            
//            let extraFromSleepDeficit = sleepDeficit * 0.6
            
            let extraFromSleepDeficit = user.sleepGoal * sleepDeficit * 0.5
            // dividing by 200 = for every 100 more than goal, they get an extra 30 min of sleep
            let extraFromExerciseSurplus = exerciseSurplus/200 * 0.2
            let extraFromCurrCal = currCal/200 * 0.3
            let extraFromWaterDeficit = user.waterGoal * waterDeficit * 0.1
            
            print("user sleep goal: \(user.sleepGoal)")
            print("extra from sleep deficit: \(extraFromSleepDeficit)")
            
            self.sleepRecommendation = user.sleepGoal + extraFromSleepDeficit + extraFromExerciseSurplus + extraFromCurrCal + extraFromWaterDeficit
            
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
            
            self.waterRecommendation = user.waterGoal + extraFromSleepDeficit + extraFromExerciseSurplus + extraFromCurrCal
            
            // update sleep goal in DB
            let todayWaterGoal = Water(amountDrank: 0, goal: Float(waterRecommendation), date: Date(), uid: user.id ?? "")
//            addToFirebase(collection: "water", obj: todayWaterGoal, date: Date())
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
//            print("extra from sleep deficit: \(extraFromSleepDeficit)")
            self.calorieRecommendation = user.exerciseGoal - minusFromSleepDeficit - minusFromExerciseSurplus - minusFromWaterDeficit
            
            
            // Update calories goal in DB
            let todayExerciseGoal = ExerciseGoal(caloriesBurned: 0, goal: calorieRecommendation, date: Date(), uid: user.id ?? "")
//            addToFirebase(collection: "exercise", obj: todayExerciseGoal, date: Date())
            updateGoalInFirebase(collection: "exercise", newGoal: self.calorieRecommendation, date: Date())
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
        print("begin calculating calories burned surplus")
        // Create date range for each day
        
        do {
            await self.fetchExerciseHistory()
            let surplus = exerciseHistory.map { exercise in
                let amt = exercise.caloriesBurned - exercise.goal
                return amt > 0 ? amt / exercise.goal : 0
            }
            
//            print("calorie history \(exerciseHistory)")
            print("calorie surplus \(surplus)")
//            self.exerciseHistory = exerciseHistory
            return calculateGradientRatio(fromRatios: surplus)
            
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func calculateGradientWaterDeficit() async -> Double {
        // TODO
        print("begin calculating gradient water deficit")
        
        let today = Calendar.current.startOfDay(for: Date())
        do {
            // Fetch sleep goal for that day
            let querySnapshot = try await db.collection("water")
                .whereField("uid", isEqualTo: user.id ?? "failed")
                .whereField("date", isLessThan: Timestamp(date: today))
                .order(by: "date", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            let waterHistory = try querySnapshot.documents.compactMap { document in
                return try document.data(as: Water.self)
            }
            
            let waterDeficits = waterHistory.map { water in
                if (water.amountDrank >= water.goal) {
                    return 0.0
                }
                
                return Double((water.goal - water.amountDrank) / water.goal)
            }
            
            print("water history \(waterHistory)")
            print("water deficits \(waterDeficits)")
            print()
            self.waterHistory = waterHistory
            return calculateGradientRatio(fromRatios: waterDeficits)
            
        } catch {
            print(error.localizedDescription)
            return 0
        }
    }
    
    func fetchPastSleepGoals() -> [Double] {

        return []
    }
    
    func getCurrentCaloriesSurplus() async -> Double {
        let currentExerciseLog = await self.fetchCurrentExerciseLog()
        let surplus = (currentExerciseLog?.caloriesBurned ?? 0) - (currentExerciseLog?.goal ?? 0)
        return surplus > 0 ? surplus : 0
    }
    
    func getExerciseHistory() -> [ExerciseGoal] {
        // TODO: Make sure that self.exerciseHistory has been fetched
//        await fetchExerciseHistory()
        
        return self.exerciseHistory
    }
    
    func getCurrentCaloriesBurned() -> Double {
        // TODO: Make sure that self.exerciseHistory has been fetched
//        await fetchExerciseHistory()
        
        print()
        print("getting current calories burned: \(self.currCaloriesBurned)")
        return self.currCaloriesBurned
    }
    
    private func fetchCurrentExerciseLog() async -> ExerciseGoal? {
        print("fetching current exercise log")
        
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
            
            print("current calories burned: \(cal!.caloriesBurned)")
            self.currCaloriesBurned = cal!.caloriesBurned
            print("self.current calories burned: \(self.currCaloriesBurned)")
            return cal!
            
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
            
            print("calorie history \(exerciseHistory)")
            self.exerciseHistory = exerciseHistory
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
        
        do {
            let doc = try self.db.collection(collection).document(docId)
            let fieldToUpdate = "goal"
            try doc.updateData([fieldToUpdate: newGoal])
        } catch {
            print("failed to update goal to firebase")
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
