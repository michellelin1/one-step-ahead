//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI

struct WaterView: View {
    @ObservedObject var viewModel = WaterViewModel()
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @EnvironmentObject var authHandler: AuthViewModel
    @State var test = ""
    var body: some View {
        VStack(alignment: .center) {
            Text("Water Recommendation: \(recommendationViewModel.waterRecommendation)")
            Text("Log your water intake")
                .font(.system(size: 35))
            TextField("8 oz", text: $viewModel.amtStr)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 30))
            // TODO: Why is it defaulting to 0.0?
            Button("Save")
            {
                viewModel.saveWater()
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) // lowers keyboard after clicking save
                
            }
            waterHistory
        }
        .onAppear {
            viewModel.fetchCurrWater()
            viewModel.fetchWaterHistory()
            recommendationViewModel.setUser(authHandler.user ?? User.empty)
            recommendationViewModel.getWaterRecommendation()
            
        }
        .padding()
    }
    
    var waterHistory: some View {
        VStack() {
            Text("Water History")
                .font(.system(size: 25))
                .padding()
            ForEach(viewModel.waterHistory) { water in
                VStack {
                    Text("\(viewModel.dateFormater(water.date))")
                    Text("\(viewModel.getTruncatedWaterValueString(water.amountDrank)) of \(viewModel.getTruncatedWaterValueString(water.goal)) cups")
                    Text("\(viewModel.getGoalMetOrUnmetString(dailyWater: water))")
                }
                .background(viewModel.wasGoalMet(dailyWater: water) ? .green : .red)
                .padding()
            }
        }
    }
}

struct WaterView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
