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
    struct WaterData: Identifiable {
        var date: String
        var count: Double
        var id = UUID()
    }
    var water_data: [WaterData] = [
        .init(date: "2/1", count: 5),
        .init(date: "2/2", count: 4),
        .init(date: "2/3", count: 6)
    ]
    var body: some View {
        VStack(alignment: .center) {
            
//            Text("Water Recommendation: \(recommendationViewModel.waterRecommendation)")
//            Text("Current Water Intake: \(recommendationViewModel.currWaterGoal.amountDrank)")
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
                    recommendationViewModel.updateWaterDrank(amt: -2)
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
            
            Text("Water Recommendation: \(recommendationViewModel.waterRecommendation)")
            Text("Current Water Intake: \(String(format: "%.2f", recommendationViewModel.currWaterGoal.amountDrank)) ounces")
               
            Chart { // chart with dummy data
                ForEach(water_data) { water in
                    BarMark(
                        x: .value("Date", water.date),
                        y: .value("Total Count", water.count)
                    )
                }
//                BarMark(
//                    x: .value("Date", data[0].type),
//                    y: .value("Total Count", data[0].count)
//                )
//                BarMark(
//                     x: .value("Date", data[1].type),
//                     y: .value("Total Count", data[1].count)
//                )
//                BarMark(
//                     x: .value("Date", data[2].type),
//                     y: .value("Total Count", data[2].count)
//                )
            }
            //waterHistory
        }
        .onAppear {
            recommendationViewModel.getWaterRecommendation()
            recommendationViewModel.getCurrentWater()
            //viewModel.fetchCurrWater()
            //viewModel.fetchWaterHistory()
        }
        .padding()
    }
    
//    var waterHistory: some View {
//        VStack() {
//            Text("Water History")
//                .font(.system(size: 25))
//                .padding()
//            ForEach(viewModel.waterHistory) { water in
//                VStack {
//                    Text("\(viewModel.dateFormater(water.date))")
//                    Text("\(viewModel.getTruncatedWaterValueString(water.amountDrank)) of \(viewModel.getTruncatedWaterValueString(water.goal)) cups")
//                    Text("\(viewModel.getGoalMetOrUnmetString(dailyWater: water))")
//                }
//                .background(viewModel.wasGoalMet(dailyWater: water) ? .green : .red)
//                .padding()
//            }
//        }
//    }
}

struct WaterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
