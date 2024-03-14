//
//  ExcerciseView.swift
//  one-step-ahead
//
//  Created by michelle on 2/6/24.
//

import SwiftUI
import Charts

struct ExerciseView: View {
    @EnvironmentObject var recommendationViewModel: RecommendationViewModel
    @EnvironmentObject var authHandler: AuthViewModel
    @EnvironmentObject var healthKitViewModel: HealthKitViewModel
    @State var weather: ResponseBody?
    let dateFormatter = DateFormatter()
    
    
    var body: some View {
        ScrollView {
            VStack{
                VStack(alignment: .leading) {
                    Text("Get Moving!")
                        .font(.system(size: 30))
                        .padding()
                }
                
                ProgressCircle(progress: Float(recommendationViewModel.currExerciseGoal.caloriesBurned/recommendationViewModel.calorieRecommendation), color: Color.green, imageName: "figure.walk", imageSize: 80, size: 180)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Text("Exercise Recommendation: \(recommendationViewModel.formatToTwoDec( recommendationViewModel.calorieRecommendation)) cal")
                // Text("Exercise history: \(recommendationViewModel.getExerciseHistory().count)")
                Text("Current calories burned: \(healthKitViewModel.formattedCalBurned()) cal")
                Text("Current calories burned rec: \(recommendationViewModel.formatToTwoDec(recommendationViewModel.currExerciseGoal.caloriesBurned)) cal")
                Spacer()
                VStack {
                    VStack {
                        Text("Try some of the following workouts to reach your exercise goal for today!")
                            .multilineTextAlignment(.center)
                        VStack {
                            ForEach(recommendationViewModel.recommendedExercises, id: \.self) { exercise in
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .padding() // Add padding to align the text
                                }
                                .background(Color.gray.opacity(0.2)) // Background color for the box
                                .cornerRadius(8) // Add corner radius for the box
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
                
            }
            
            Chart {
                ForEach(recommendationViewModel.allExerciseHistory) { exercise in
                    BarMark(
                        x: .value("Date", recommendationViewModel.formatDate(exercise.date)),
                        y: .value("Total Count", exercise.caloriesBurned)
                    )
                    .foregroundStyle(.green)
                }
                
            }
            .frame(width: .infinity, height: 230)
        }
    }
}

struct ExcerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView()
    }
}
