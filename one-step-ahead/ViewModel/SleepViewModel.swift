//
//  SleepViewModel.swift
//  one-step-ahead
//
//  Created by michelle on 2/7/24.
//

import SwiftUI

class SleepViewModel: ObservableObject {
    @Published var selectedHours = 0
    @Published var selectedMinutes = 0
        
    // Computed property to calculate total nap length in seconds
    var napLength: TimeInterval {
        return TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
    }
    
    func formattedNapDuration(_ napTime: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: napTime) ?? "N/A"
    }
}
