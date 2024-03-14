//
//  SleepView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI

struct SleepView: View {
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var sleepViewModel: SleepViewModel
    
    @State private var showPickers = false
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    
    private var napLength: TimeInterval {
        return TimeInterval(selectedHours * 3600 + selectedMinutes * 60)
    }
    
    func getNapLength() -> TimeInterval {
            return napLength
        }

    
    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                Text("Get Some Rest!")
                    .font(.system(size: 30))
                    .padding()
            }
            let sleepGoal = recommendationViewModel.sleepHistory.count > 0 ? recommendationViewModel.sleepHistory[0].goal : 1
            ProgressCircle(progress: Float(recommendationViewModel.currSleepDuration.sleepDuration + ((recommendationViewModel.currSleepDuration.napTime ?? 0))) / Float(sleepGoal), color: Color.purple, imageName: "moon.zzz.fill", imageSize: 80, size: 180)
                .frame(width: 200, height: 200)
                .padding()
           
            
            // Display selected nap length
            Text("Sleep Recommendation: \(formatTimeInterval(TimeInterval(sleepGoal * 3600)))")
                                .padding()
            
            // Display selected nap length
            Text("Nap Length: \(formatTimeInterval(TimeInterval(((recommendationViewModel.currSleepDuration.napTime) ?? 0) * 3600)))")
                                .padding()
            
            Button(action: {
                   self.showPickers.toggle()
               }) {
                   Text("Edit Nap Length")
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(Color.white)
                       .cornerRadius(8)
               }
            
            if showPickers {
                HStack {
                    // Picker for selecting hours
                    Picker("Hours", selection: $sleepViewModel.selectedHours) {
                        ForEach(0..<10, id: \.self) { hour in
                            Text("\(hour) hr")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100).clipped()
                    
                    // Picker for selecting minutes
                    Picker("Minutes", selection: $sleepViewModel.selectedMinutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute) min")
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100).clipped()
                    Button("save") {
                        recommendationViewModel.updateSleep(napTime: sleepViewModel.napLength)
                        self.showPickers.toggle()
                    }
                }
               
            }
            Spacer()
        }

    }
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "0"
    }
}

struct SleepView_Previews: PreviewProvider {
    static var previews: some View {
        SleepView()
    }
}
