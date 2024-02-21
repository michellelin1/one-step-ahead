//
//  UserModel.swift
//  one-step-ahead
//
//  Created by michelle on 2/12/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var firstName: String
    var lastName: String
    var waterGoal: Double
    var sleepGoal: Double
    var exerciseGoal: Double
}

extension User {
    static var empty = User(id: "empty", firstName: "", lastName: "", waterGoal: 0, sleepGoal: 0, exerciseGoal: 0)
}
