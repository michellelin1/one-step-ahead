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
    @Published var currWater: Water = Water(amountDrank: 0, goal: 3, date: Date(), uid: "uid")
    @Published var waterHistory: [Water] = []
    @Published var amtStr = ""
    
    private var db = Firestore.firestore()
    
    func fetchCurrWater() {
        Task {
            do {
                let path = "water/uid"+dateFormater(Date())
                self.currWater = try await db.document(path).getDocument(as: Water.self)
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
                                            .whereField("uid", isEqualTo: "uid")
                                            .getDocuments()
                waterHistory = try querySnapshot.documents.compactMap { document in
                    var decodedDoc = try document.data(as: Water.self)
                    decodedDoc.id = document.documentID
                    return decodedDoc
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func saveWater() {
        do {
            self.currWater.amountDrank = Float(amtStr) ?? self.currWater.amountDrank
            let path = "water/uid"+dateFormater(Date())
            try db.document(path).setData(from: currWater)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func dateFormater(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: date)
    }

}
