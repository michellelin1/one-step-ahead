//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI
import Charts

struct WaterView: View {
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @State var amtStr = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("Log Your Water Intake!")
                        .font(.system(size: 30))
                        .padding()
                }
                ProgressCircle(progress: Float(recommendationViewModel.currWaterGoal.amountDrank/recommendationViewModel.waterRecommendation), color: Color.blue, imageName: "drop.fill", imageSize: 80, size: 180)
                    .frame(width: 200, height: 200)
                    .padding(.top)
                HStack {
                    Button(action: {
                        recommendationViewModel.updateWaterDrank(amt: -1)
                    }) {
                        Text("−")
                            .font(.system(size: 70))
                    }
                    
                    Button(action: {
                        recommendationViewModel.updateWaterDrank(amt: 2)
                    }) {
                        Text("+")
                            .font(.system(size: 70))
                    }
                    .padding(.bottom)
                }
                
                Text("Water Recommendation: \(recommendationViewModel.formatToTwoDec(recommendationViewModel.waterRecommendation)) oz")
                Text("Current Water Intake: \(String(format: "%.2f", recommendationViewModel.currWaterGoal.amountDrank)) oz")
                
                Chart {
                    ForEach(recommendationViewModel.allWaterHistory) { water in
                        BarMark(
                            x: .value("Date", recommendationViewModel.formatDate(water.date)),
                            y: .value("Total Count", water.amountDrank)
                        )
                    }
                    
                }
                .frame(width: .infinity, height: 230)
            }
            .padding()
        }
    }
    
}

struct WaterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
