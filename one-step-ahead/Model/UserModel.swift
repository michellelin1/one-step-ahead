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
    var waterGoal: Float
    var sleepGoal: Float
    var exerciseGoal: Float
}
