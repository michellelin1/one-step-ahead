//
//  ContentView.swift
//  one-step-ahead
//
//  Created by Meggie Nguyen on 2/6/24.
//

import SwiftUI
import HealthKit

struct HealthKitView: View {
    @State private var sleepDuration: TimeInterval = 0
    @State private var weight: Double?
    @State private var height: Double?
    @State private var biologicalSex: HKBiologicalSex?
    @State private var stepCount: Int = 0
    @State private var workouts: [HKWorkout] = []
    @State private var isAuthorized: Bool = false
    @State private var caloriesBurned: Double?
    @State private var sleep: Double?
    
    let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            Text("Sleep Duration: \(formattedSleepDuration())")
                .padding()
            Text("Weight: \(formattedWeight())")
                .padding()
            Text("Height: \(formattedHeight())")
                .padding()
            Text("Biological Sex: \(formattedBiologicalSex())")
                .padding()
            Text("Workouts: \(workouts.count)")
                .padding()
            Text("Calories Burned: \(formattedCalBurned())")
                .padding()
            Button("Authorize Health Data") {
                requestAuthorization()
            }
            .padding()
            .disabled(HKHealthStore.isHealthDataAvailable())
        }
        .onAppear {
            checkAuthorizationStatus()
        }
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
        }
        
        func fetchSleepDuration() {
            
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
                }

            }
        
        healthStore.execute(query)
    }
}


#Preview {
    HealthKitView()
}
