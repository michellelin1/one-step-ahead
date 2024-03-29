//
//  ExerciseModel.swift
//  one-step-ahead
//
//  Created by michelle on 2/7/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ExerciseGoal: Codable, Identifiable {
    @DocumentID var id: String?
    var caloriesBurned: Double
    var goal: Double
    var date: Date
    var uid: String
}

extension ExerciseGoal {
    static var empty = ExerciseGoal(caloriesBurned: 0, goal: 1, date: Date(), uid: "exercise")
}
