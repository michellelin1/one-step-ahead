//
//  HealthKitManager.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import Foundation
import SwiftUI
import HealthKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class HealthKitViewModel: ObservableObject {
    @Published var sleepDuration: TimeInterval = 0
    @Published var weight: Double?
    @Published var height: Double?
    @Published var age: Int?
    @Published var biologicalSex: HKBiologicalSex?
    @Published var stepCount: Int = 0
    @Published var workouts: [HKWorkout] = []
    @Published var isAuthorized: Bool = false
    @Published var caloriesBurned: Double?
    @Published var sleep: Double?
    
    private var sleepDurationFetched: Bool = false
        
    private var healthStore: HKHealthStore;
    private var db = Firestore.firestore()
    private var user = User.empty;
    
    init() {
        healthStore = HKHealthStore()
    }
    
    func setUserId(_ user: User) {
        self.user = user
    }
    
    func formattedSleepDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: sleepDuration) ?? "N/A"
    }
    
    func formattedWeight() -> String {
        guard let weight = weight else { return "N/A" }
        let weightInPounds = weight
        return String(format: "%.0f lbs", weightInPounds)
    }
    
    func formattedHeight() -> String {
        guard let height = height else { return "N/A" }
        let heightInFeet = floor(height / 12)
        let heightInInches = height.truncatingRemainder(dividingBy: 12)
            
        return String(format: "%.0f' %.0f\"", heightInFeet, heightInInches)
    }
    
    func formattedBiologicalSex() -> String {
        guard let biologicalSex = biologicalSex else { return "N/A" }
        switch biologicalSex {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        default:
            return "Unknown"
        }
    }

    func formattedWorkouts() -> Int {
        return workouts.count
    }
        
    func formattedCalBurned() -> String {
        guard let caloriesBurned = caloriesBurned else { return "0" }
        return String(format: "%.1f calories", caloriesBurned)
    }
    
    func checkAuthorizationStatus() {
        let healthKitTypesToRead: Set<HKObjectType> = [
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.workoutType()
        ]

        healthStore.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            if success {
                self.isAuthorized = true // Update authorization status
                self.fetchHealthData()
            } else {
                print("Error requesting HealthKit authorization: \(String(describing: error))")
            }
        }
    }
    
    func requestAuthorization() {
        checkAuthorizationStatus()
    }
    
    func fetchHealthData() {
        // Fetch sleep duration
        fetchSleepDuration()
        
        // Fetch weight
        fetchWeight()
        
        // Fetch height
        fetchHeight()
        
        // Fetch biological sex
        fetchBiologicalSex()
    
        // Fetch calories burned
        fetchCaloriesBurned()
        
        fetchUserAge()
    }
    
    func generateBaselineExerciseGoal() -> Double {
        // For men: 66.47 + (6.24 × weight in pounds) + (12.7 × height in inches) − (6.75 × age in years) . For women: BMR = 65.51 + (4.35 × weight in pounds) + (4.7 × height in inches) - (4.7 × age in years)
        var bmr: Double = 66.47 + (6.24 * (self.weight ?? 1))
        bmr += (12.7 * (self.height ?? 1))
        bmr -= (6.75 * Double((self.age ?? 1)))
        
        if (self.biologicalSex == .female) {
            bmr = 65.51 + (4.35 * (self.weight ?? 1))
            bmr += (4.7 * (self.height ?? 1))
            bmr -= (4.7 * Double((self.age ?? 1)))
        }
        return bmr * 0.4
    }
    
    func generateBaselineWaterGoal() -> Double {
        // basic water rec 48oz
//        var waterRec = 48
//        if (self.biologicalSex == .female) {
//            waterRec += (self.height - 64) * 3
//        } else if (self.biologicalSex == .male) {
//            waterRec += (self.height - 69) * 3
//        }
//
//        let bmi = 703 * self.weight / (self.height * self.height)
        
        return (self.weight ?? 0) / 2
    }
    
    func generateBaselineSleepGoal() -> Double {
        if (self.age ?? 0 >= 18) {
            return 7
        } else {
            return 8
        }
    }
    
    func fetchUserAge() {
        guard let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth) else {
                print("Date of Birth type is not available.")
                return
            }
        
        do {
            let dateOfBirth = try healthStore.dateOfBirth()
            
            // Calculate the age
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
            
            DispatchQueue.main.async {
                print("age \(ageComponents.year)")
                self.age = ageComponents.year
            }
        } catch {
            print("failed retrieving age")
        }
    }
        
        func fetchSleepDuration() {
            if self.sleepDurationFetched {
                return
            }
            
            // Prepare the query to fetch sleep data
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            let startOfToday = Calendar.current.startOfDay(for: Date())
            let sampleIntervalStartDate = Calendar.current.date(byAdding: .hour, value: -6, to: startOfToday)! // 6PM yesterday
            let sampleIntervalEndDate = Calendar.current.date(byAdding: .hour, value: 16, to: startOfToday)! // 4PM today
            let sampleOptions: HKQueryOptions = [.strictStartDate, .strictEndDate]
            
            print("sampleIntervalStartDate: \(sampleIntervalStartDate)")
            print("sampleIntervalEndDate: \(sampleIntervalEndDate)")
            
            let samplePredicate = HKQuery.predicateForSamples(withStart: sampleIntervalStartDate, end: sampleIntervalEndDate, options: sampleOptions)
            
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: samplePredicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { (query, results, error) in
                guard let samples = results as? [HKCategorySample], error == nil else {
                    if let error = error {
                        print("Error fetching sleep data: \(error.localizedDescription)")
                    } else {
                        print("Failed to fetch sleep data.")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    // Process fetched sleep data
                    let asleepValues = [3, 4, 5] // 3: asleepCore, 4: asleepDeep, 5: asleepREM
                    
                    for sample in samples {
                        if (asleepValues.contains(sample.value)) {
                            let startDate = sample.startDate
                            let endDate = sample.endDate
                            let value = sample.value
                            
                            
//                            print("Sleep start: \(startDate), end: \(endDate), value: \(value)")
//                            print()
                            
                            self.sleepDuration += endDate.timeIntervalSince(startDate)
                        }
                    }
                    
                    let sleepDurationObj = SleepDuration(sleepDuration: self.sleepDuration/3600, goal: self.user.sleepGoal, date: sampleIntervalStartDate, uid: self.user.id ?? "failed")
//                    let prevDay = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
                    self.addToFirebase(collection: "sleep", obj: sleepDurationObj, amt: self.sleepDuration/3600, date: sampleIntervalStartDate)
//                    print("sleepDurationObj duration: \(sleepDurationObj.sleepDuration)")
//                    print("sleepDurationObj date: \(sleepDurationObj.date)")
                    self.sleepDurationFetched = true
                    
                }
            }
            
            healthStore.execute(query)
        }
        
        func fetchWeight() {
            guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
                    print("Weight type is not available.")
                    return
                }
                
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { query, results, error in
                    guard let weightSample = results?.first as? HKQuantitySample else {
                        if let error = error {
                            print("Failed to fetch weight sample: \(error.localizedDescription)")
                        } else {
                            print("No weight data available.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let weightInKilo = weightSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                        let weightInPounds = weightInKilo * 2.20462
                        self.weight = weightInPounds
                        // You can then use this value as needed, such as calculating BMI.
                    }
                }
                
                healthStore.execute(query)
            
        }
        
        func fetchHeight() {
            guard let heightType = HKObjectType.quantityType(forIdentifier: .height) else {
                    print("Height type is not available.")
                    return
                }
                
                let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { query, results, error in
                    guard let heightSample = results?.first as? HKQuantitySample else {
                        if let error = error {
                            print("Failed to fetch height sample: \(error.localizedDescription)")
                        } else {
                            print("No height data available.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let heightInInch = heightSample.quantity.doubleValue(for: HKUnit.inch())
                        self.height = heightInInch
                        // You can then use this value as needed, such as calculating BMI.
                    }
                }
                
                healthStore.execute(query)
          }
        
    func fetchBiologicalSex() {
        do {
            let biologicalSex = try healthStore.biologicalSex()
            DispatchQueue.main.async {
                self.biologicalSex = biologicalSex.biologicalSex
            }
            
        } catch {
            print("Error fetching biological sex: \(error.localizedDescription)")
        }
    }
    
    func fetchCaloriesBurned() {
        guard let caloriesBurnedType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Active energy burned type is not available.")
            return
        }
        
        let calendar = Calendar.current
            let now = Date()
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // Create a predicate for samples within today
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            // Create a query to retrieve calories burned samples for today
            let query = HKStatisticsQuery(quantityType: caloriesBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
                guard let result = result else {
                    if let error = error {
                        print("Failed to fetch calories burned data with error: \(error.localizedDescription)")
                    } else {
                        print("No calories burned data available for today.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    if let sum = result.sumQuantity() {
                        let caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
                        self.caloriesBurned = caloriesBurned
                    } else {
                        print("No calories burned data available for today.")
                    }
                    // adding to the db
                    let exerciseObj = ExerciseGoal(caloriesBurned: self.caloriesBurned ?? 0, goal: self.user.exerciseGoal, date: Date(), uid: self.user.id ?? "failed")
                    self.addToFirebase(collection: "exercise", obj: exerciseObj, amt: self.caloriesBurned ?? 0, date: Date())

                }

            }
        
        healthStore.execute(query)
    }
    
    func addToFirebase(collection: String, obj: Codable, amt: Double, date: Date) {
        print("adding \(collection) info to firebase")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateStr = dateFormatter.string(from: date)
        let docId = (self.user.id ?? "failed") + dateStr
        let doc = db.collection(collection).document(docId)
        
        Task {
            do {
                let documentSnapshot = try await doc.getDocument()
                if (documentSnapshot.exists) {
                    print("document exists")
                    var fieldToUpdate = "caloriesBurned"
                    if collection == "sleep" {
                        fieldToUpdate = "sleepDuration"
                    }
                    try await doc.updateData([fieldToUpdate: amt])
                } else {
                    print("doc doesn't exist")
                    try doc.setData(from: obj)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

