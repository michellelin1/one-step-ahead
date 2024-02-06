//
//  ContentView.swift
//  one-step-ahead
//
//  Created by michelle on 2/2/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = WaterViewModel()
    @State var test = ""
    var body: some View {
        VStack {
            TextField("8 oz", text: $viewModel.amtStr)
            Button("save"){
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
        VStack(alignment: .leading) {
            Text("Water History")
            ForEach(viewModel.waterHistory) { water in
                Text("\(viewModel.dateFormater(water.date))")
                Text("\(water.amountDrank/water.goal)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
