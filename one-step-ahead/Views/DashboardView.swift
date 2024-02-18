//
//  DashboardView.swift
//  one-step-ahead
//
//  Created by Mia Schroeder on 2/12/24.
//

import SwiftUI

struct DashboardView: View {
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let buttonColors: [Color] = [.green, .blue, .purple, .pink]
    @State private var showExerciseView = false
    @State private var showWaterView = false
    @State private var showSleepView = false
    
    var body: some View {
        NavigationStack {
            // TODO: Fetch actual name
            VStack(alignment: .leading) {
                Text("Welcome back, Michelle!")
                    .font(.system(size: 30))
                    .padding()
            }
            VStack {
                // TODO: Link button to page
                LazyVGrid(columns: columns, spacing: 20) {
                    Button(action: {
                        // Action for the first button
                        print("First button tapped")
                    }) {
                        buttonContent(imageName: "figure.walk.circle", text: "exercise activity", backgroundColor: buttonColors[0])
                    }
                    .navigationDestination(isPresented: $showExerciseView) {ExerciseView()}
                    
                    Button(action: {
                        print("Second button tapped")
                    }) {
                        buttonContent(imageName: "drop.circle", text: "water intake", backgroundColor: buttonColors[1])
                    }
                    .navigationDestination(isPresented: $showExerciseView) {WaterView()}
                    
                    Button(action: {
                        // Action for the third button
                        print("Third button tapped")
                    }) {
                        buttonContent(imageName: "moon.circle", text: "sleep patterns", backgroundColor: buttonColors[2])
                    }
                    .navigationDestination(isPresented: $showWaterView) {SleepView()}
                    
                    Button(action: {
                        // Action for the fourth button
                        print("Fourth button tapped")
                    }) {
                        buttonContent(imageName: "square.and.pencil.circle", text: "log my activity", backgroundColor: buttonColors[3])
                    }
                    .navigationDestination(isPresented: $showExerciseView) {ExerciseView()}
                }
                .padding()
            }
        }
    }
    
    private func buttonContent(imageName: String, text: String, backgroundColor: Color) -> some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.horizontal, 10)
                .foregroundColor(Color.white) // color of the icons
            
            Text(text)
                .foregroundColor(Color.white)
                .padding(.horizontal, 2)
        }
        .frame(width: 132, height: 150)
        .padding()
        .background(backgroundColor) // Customize the background color if needed
        .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
}
