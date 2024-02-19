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
    
    var body: some View {
        NavigationView{
            VStack {
                VStack(alignment: .leading) {
                    // TODO: Fetch actual name
                    Text("Welcome back, Michelle!")
                        .font(.system(size: 30))
                        .padding()
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    
                    NavigationLink(destination: ExerciseView()) {
                        buttonContent(imageName: "figure.walk.circle", text: "exercise activity", backgroundColor: buttonColors[0])
                    }
                    NavigationLink(destination: WaterView()) {
                        buttonContent(imageName: "drop.circle", text: "water intake", backgroundColor: buttonColors[1])
                    }
                    NavigationLink(destination: SleepView()) {
                        buttonContent(imageName: "moon.circle", text: "sleep patterns", backgroundColor: buttonColors[2])
                    }
                    NavigationLink(destination: HealthKitView()) {
                        buttonContent(imageName: "person.circle", text: "profile", backgroundColor: buttonColors[3])
                    }
                    .padding()
                }
                .padding()
                
                VStack(alignment: .trailing) {
                    Text("Recommendations")
                    .font(.system(size: 30))
                }
                Spacer()
            }
            .navigationTitle("Dashboard")
            
            VStack(alignment: .trailing) {
                // TODO: Fetch actual name
                Text("Recommendations")
                    .font(.system(size: 30))
                    .padding()
            }

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



#Preview {
    DashboardView()
}
