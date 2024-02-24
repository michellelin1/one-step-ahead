//
//  WaterViewModel.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class WaterViewModel: ObservableObject {
    @Published var currWater: Water = Water(amountDrank: 0, goal: 3, date: Calendar.current.startOfDay(for: Date()), uid: "uid")
    @Published var waterHistory: [Water] = []
    @Published var amtStr = ""
    let today = Calendar.current.startOfDay(for: Date())
    var uid = "uid"

    
    private var db = Firestore.firestore()
    
    func fetchCurrWater() {
        Task {
            do {
                let querySnapshot = try await db.collection("water")
                                            .whereField("uid", isEqualTo: uid)
                                            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: today))
                                            .limit(to: 1)
                                            .getDocuments()
                let water = querySnapshot.documents.first.flatMap { document in
                    try? document.data(as: Water.self)
                }
                self.currWater = water ?? self.currWater
                self.amtStr = String(currWater.amountDrank)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchWaterHistory() {
        Task {
            do {
                let querySnapshot = try await db.collection("water")
                                            .whereField("uid", isEqualTo: uid)
                                            .whereField("date", isLessThan: Timestamp(date: today))
                                            .order(by: "date", descending: true)
                                            .limit(to: 3)
                                            .getDocuments()
                waterHistory = try querySnapshot.documents.compactMap { document in
                    return try document.data(as: Water.self)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func saveWater() {
        do {
            self.currWater.amountDrank = Float(amtStr) ?? self.currWater.amountDrank
            if self.currWater.id == nil {
                let doc = try db.collection("water").addDocument(from: currWater)
                self.currWater.id = doc.documentID
            } else {
                try db.collection("water").document(self.currWater.id ?? "failed").setData(from: currWater)
                
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func dateFormater(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }
    
    func getTruncatedWaterValueString(_ value: Float) -> String {
        let truncatedWaterString = String(format: "%.2f", value)
        return truncatedWaterString
    }
    
    func getGoalMetOrUnmetString(dailyWater water: Water) -> String {
        let goalStatus = water.amountDrank / water.goal
        if (goalStatus >= 1) {
            return "Goal met :)"
        } else {
            return "Goal not met :("
        }
    }
    
    func wasGoalMet(dailyWater water: Water) -> Bool {
        return (water.amountDrank / water.goal) >= 1
    }
    
}
