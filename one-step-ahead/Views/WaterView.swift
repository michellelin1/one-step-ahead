//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI

struct WaterView: View {
    @ObservedObject var viewModel = WaterViewModel()
    @State var test = ""
    var body: some View {
        VStack {
            Text("Log your water intake")
                .font(.system(size: 35))
            TextField("8 oz", text: $viewModel.amtStr)
                .multilineTextAlignment(.center)
                .font(.system(size: 30))
            // TODO: Why is it defaulting to 0.0?
            Button("Save")
            {
                viewModel.saveWater()
            }
            waterHistory
        }
        .onAppear {
            viewModel.fetchCurrWater()
            viewModel.fetchWaterHistory()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WaterView()
    }
}
