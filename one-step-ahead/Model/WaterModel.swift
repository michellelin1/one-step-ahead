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
    var amountDrank: Float
    var goal: Float
    var date: Date
    var uid: String
}


