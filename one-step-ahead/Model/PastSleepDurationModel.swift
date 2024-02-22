//
//  PastSleepDurationModel.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/20/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SleepDuration: Codable, Identifiable {
    @DocumentID var id: String?
    var sleepDuration: TimeInterval // stored in hours
    var goal: Double
    var date: Date //startDate, i.e., the day they went to sleep
    var uid: String
}
