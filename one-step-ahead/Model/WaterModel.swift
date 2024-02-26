//
//  WaterModel.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Water: Codable, Identifiable {
    @DocumentID var id: String?
    var amountDrank: Double
    var goal: Double
    var date: Date
    var uid: String
}

extension Water {
    static var empty = Water(amountDrank: 0, goal: 0, date: Date(), uid: "water-empty")
}
