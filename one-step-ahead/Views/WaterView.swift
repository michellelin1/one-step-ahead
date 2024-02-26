//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI

struct WaterView: View {
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @State var amtStr = ""
    var body: some View {
        VStack(alignment: .center) {
            Text("Water Recommendation: \(recommendationViewModel.waterRecommendation)")
            Text("current water intake: \(recommendationViewModel.currWaterGoal.amountDrank)")
            Text("Log your water intake")
                .font(.system(size: 35))
            ProgressCircle(progress: Float(recommendationViewModel.currWaterGoal.amountDrank/recommendationViewModel.waterRecommendation), color: Color.blue, imageName: "drop.fill", size: 200)
            Button("+")
            {
                recommendationViewModel.updateWaterDrank(amt: 2)
                
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
