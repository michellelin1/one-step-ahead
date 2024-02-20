//
//  HealthKitManager.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import Foundation
import SwiftUI
import HealthKit

class HealthKitViewModel: ObservableObject {
    @Published var sleepDuration: TimeInterval = 0
    @Published var weight: Double?
    @Published var height: Double?
    @Published var biologicalSex: HKBiologicalSex?
    @Published var stepCount: Int = 0
    @Published var workouts: [HKWorkout] = []
    @Published var isAuthorized: Bool = false
    @Published var caloriesBurned: Double?
    @Published var sleep: Double?
    
    private var healthStore: HKHealthStore;
    
    init() {
        healthStore = HKHealthStore()
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
        }
        
        func fetchSleepDuration() {
            let sleepSampleType = HKCategoryType(.sleepAnalysis)
            
            let calendar = Calendar.current

            // Get the current date and time
            let currentDate = Date()

            // Get the date components for yesterday
            var yesterdayComponents = DateComponents()
            yesterdayComponents.day = -1

            // Calculate the date for yesterday
            guard let yesterday = calendar.date(byAdding: yesterdayComponents, to: currentDate) else {
                fatalError("Failed to calculate yesterday's date")
            }

            // Create date components for 8 PM
            var yesterdayEightPMComponents = DateComponents()
            yesterdayEightPMComponents.hour = 20 // 8 PM
            yesterdayEightPMComponents.minute = 0
            yesterdayEightPMComponents.second = 0

            // Calculate the date for yesterday at 8 PM
            guard let yesterdayEightPM = calendar.date(byAdding: yesterdayEightPMComponents, to: yesterday) else {
                fatalError("Failed to calculate yesterday's date at 8 PM")
            }
            
            
            let sleepCategory = HKCategoryValueSleepAnalysis.asleepCore.rawValue
            let deepSleepSample  = HKCategorySample(type: sleepSampleType,
                                                    value:sleepCategory,
                                                    start: yesterdayEightPM,
                                                    end: Date())
            
            print("Getting sleep sample: ")
            print(deepSleepSample)
            print("Done getting sleep sample")
//            self.sleepDuration = deepSleepSample
            
            // Prepare the query to fetch sleep data
            let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: nil,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { (query, results, error) in
                guard let samples = results as? [HKCategorySample], error == nil else {
                    if let error = error {
                        print("Error fetching sleep data: \(error.localizedDescription)")
                    } else {
                        print("Failed to fetch sleep data.")
                    }
                    return
                }
                
                // Process fetched sleep data
                for sample in samples {
                    let startDate = sample.startDate
                    let endDate = sample.endDate
                    let value = sample.value
                    print("Sleep start: \(startDate), end: \(endDate), value: \(value)")
                    self.sleepDuration = endDate.timeIntervalSince(startDate)
                }
            }
            
            // Execute the query
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
                }

            }
        
        healthStore.execute(query)
    }
}
