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
    
    @Published var weekOfSleep: [SleepDuration] = []
    @Published var weekOfExercise: [ExerciseGoal] = []
    @Published var weekOfWater: [Water] = []
    
    private var db = Firestore.firestore()
    private var user = User.empty
    
    func setUser(_ user: User) {
        self.user = user
        // self.sleepRecommendation = user.sleepGoal
        // self.calorieRecommendation = user.exerciseGoal
        // self.waterRecommendation = user.waterGoal
    }
    
    func initializeAllRec() {
        getSleepRecommendation()
        getWaterRecommendation()
        getCaloriesRecommendation()
        
        getCurrentSleepDuration()
        getCurrentCaloriesBurned()
        getCurrentWater()
        
        getWeekOfSleep()
        getWeekOfExercise()
        getWeekOfWater()
    }
    
    func getWeekOfSleep() {
        Task {
            do {
                let querySnapshot = try await db.collection("sleep")
                    .whereField("uid", isEqualTo: user.id ?? "failed")
                    .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek()))
                    .order(by: "date", descending: false)
                    .getDocuments()
                
                let sleepHistory = try querySnapshot.documents.compactMap { document in
                    return try document.data(as: SleepDuration.self)
                }
                
                DispatchQueue.main.async {
                    self.weekOfSleep = Array(repeating: SleepDuration.empty, count: 7)
                    for s in sleepHistory {
                        let weekday = Calendar.current.component(.weekday, from: s.date)
                        self.weekOfSleep[weekday-1] = s
                    }
                }
            } catch {
                print("fetch sleep error")
                print(error.localizedDescription)
            }
        }
    }
    
    func getWeekOfExercise() {
        Task {
            do {
                let querySnapshot = try await db.collection("exercise")
                    .whereField("uid", isEqualTo: user.id ?? "failed")
                    .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek()))
                    .order(by: "date", descending: false)
                    .getDocuments()
                
                let exerciseHistory = try querySnapshot.documents.compactMap { document in
                    return try document.data(as: ExerciseGoal.self)
                }
                
                DispatchQueue.main.async {
                    self.weekOfExercise = Array(repeating: ExerciseGoal.empty, count: 7)
                    for e in exerciseHistory {
                        let weekday = Calendar.current.component(.weekday, from: e.date)
                        self.weekOfExercise[weekday-1] = e
                    }
                }
            } catch {
                print("fetch exercise week error \(error.localizedDescription)")
                print(error.localizedDescription)
            }
        }
    }
    
    func getWeekOfWater() {
        Task {
            do {
                let querySnapshot = try await db.collection("water")
                    .whereField("uid", isEqualTo: user.id ?? "failed")
                    .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfWeek()))
                    .order(by: "date", descending: false)
                    .getDocuments()
                
                let waterHistory = try querySnapshot.documents.compactMap { document in
                    return try document.data(as: Water.self)
                }
                
                DispatchQueue.main.async {
                    self.weekOfWater = Array(repeating: Water.empty, count: 7)
                    for w in waterHistory {
                        let weekday = Calendar.current.component(.weekday, from: w.date)
                        self.weekOfWater[weekday-1] = w
                    }
                }
            } catch {
                print("fetch sleep error")
                print(error.localizedDescription)
            }
        }
    }
    
    private func startOfWeek() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: components)!
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
                // update sleep goal in DB
                let todaySleepGoal = SleepDuration(sleepDuration: 0, goal: self.sleepRecommendation, date: Date(), uid: self.user.id ?? "")
                self.addToFirebase(collection: "sleep", obj: todaySleepGoal, date: Date())
            }
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
                // update sleep goal in DB
                self.updateGoalInFirebase(collection: "water", newGoal: self.waterRecommendation, date: Date())
            }
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
                // Update calories goal in DB
                self.updateGoalInFirebase(collection: "exercise", newGoal: self.calorieRecommendation, date: Date())
            }
        }
    }
    
    // ------------ GETTER + SETTER FUNCTIONS -------------
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
    
    func getCurrentSleepDuration() {
        Task {
            await fetchCurrentSleepDuration()
        }
    }
    
    func getCurrentWater() {
        Task {
            await fetchCurrWater()
        }
    }
    
    func updateWaterDrank(amt: Double) {
        print("updating water amt drank")
        self.currWaterGoal.amountDrank += amt
        do {
            try db.collection("water").document(self.currWaterGoal.id ?? "update-failed").setData(from: self.currWaterGoal)
        } catch {
            print("failed to update water amt")
            print(error.localizedDescription)
        }
    }
    
    func updateSleep(napTime: TimeInterval) {
        print("updating nap time")
        self.currSleepDuration.napTime = napTime
        do {
            try db.collection("sleep").document(self.currSleepDuration.id ?? "update-failed").setData(from: self.currSleepDuration)
        } catch {
            print("failed setting update sleep")
            print(error.localizedDescription)
        }
    }
    
    func formatToTwoDec(_ calories: Double) -> String {
        return String(format: "%.1f", calories)
    }
    
    // ----------- HELPER FUNCTIONS ---------------
    private func calculateGradientSleepDeficit() async -> Double {
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
    
    private func fetchCurrentSleepDuration() async {
        print("fetching current sleep log")
        let today = Calendar.current.startOfDay(for: Date())
        let prevDay = Calendar.current.date(byAdding: .day, value: -1, to: today)!
    
        let docId = getDocId(date: prevDay)
        let doc = self.db.collection("sleep").document(docId)
        
        do {
            let sleep = try await doc.getDocument(as: SleepDuration.self)
            DispatchQueue.main.async {
                print("current sleep duration: \(sleep.sleepDuration)")
                self.currSleepDuration = sleep
            }
        } catch {
            print("Error fetching current sleep log")
        }
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
    
    private func calculateGradientCaloricSurplus() async -> Double {
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
    
    private func calculateGradientWaterDeficit() async -> Double {
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
    
    private func fetchCurrWater() async {
        let today = Calendar.current.startOfDay(for: Date())
        do {
            let querySnapshot = try await db.collection("water")
                                        .whereField("uid", isEqualTo: user.id ?? "failed")
                                        .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
                                        .limit(to: 1)
                                        .getDocuments()
            let water = querySnapshot.documents.first.flatMap { document in
                try? document.data(as: Water.self)
            }
            
            DispatchQueue.main.async {
                self.currWaterGoal = water ?? self.currWaterGoal
            }
        } catch {
            print(error.localizedDescription)
        }
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
    
    
    private func getCurrentCaloriesSurplus() async -> Double {
        let currentExerciseLog = await self.fetchCurrentExerciseLog()
        let surplus = (currentExerciseLog?.caloriesBurned ?? 0) - (currentExerciseLog?.goal ?? 0)
        return surplus > 0 ? surplus : 0
    }
    
    private func fetchCurrentExerciseLog() async -> ExerciseGoal? {
        print("fetching current exercise log")
        let docId = getDocId(date: Date())
        let doc = self.db.collection("exercise").document(docId)
        
        do {
            let exercise = try await doc.getDocument(as: ExerciseGoal.self)
            DispatchQueue.main.async {
                print("current exercise goal: \(exercise.caloriesBurned)")
                self.currExerciseGoal = exercise
            }
            return exercise
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
    
    private func addToFirebase(collection: String, obj: Codable, date: Date) {
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
    
    private func updateGoalInFirebase(collection: String, newGoal: Double, date: Date) {
        print("updating \(collection) goal to firebase")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        let docId = (self.user.id ?? "failed") + dateStr
        let doc = self.db.collection(collection).document(docId)
        
        // checking if the doc exists; if not create
        Task {
            do {
                let documentSnapshot = try await doc.getDocument()
                if (documentSnapshot.exists) {
                    let fieldToUpdate = "goal"
                    try await doc.updateData([fieldToUpdate: newGoal])
                } else {
                    try doc.setData(from: Water(amountDrank: 0, goal: Double(newGoal), date: Date(), uid: user.id ?? "failed"))
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func calculateGradientRatio(fromRatios ratios: [Double]) -> Double {
        var gradientRatio: Double = 0
        var numDaysBeforeToday = 1
        for ratio in ratios {
            gradientRatio += pow(0.5, Double(numDaysBeforeToday)) * ratio
            
            print("numDaysBeforeToday: \(numDaysBeforeToday), gradientRatio: \(gradientRatio)")
            
            numDaysBeforeToday += 1
        }
        
        return gradientRatio
    }
    
    private func getDocId(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        let docId = (self.user.id ?? "failed") + dateStr
        return docId
    }
}
