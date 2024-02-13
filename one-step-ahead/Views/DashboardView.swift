//
//  DashboardView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        // TODO: Fetch actual name
        VStack(alignment: .leading) {
                Text("Welcome back, Michelle!")
                .font(.system(size: 30))
                .padding()
                Spacer()
            }
//            .navigationBarTitle("Hello", displayMode: .inline)
    }
}

#Preview {
    DashboardView()
}
