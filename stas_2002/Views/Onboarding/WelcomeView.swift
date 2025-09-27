//
//  WelcomeView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            VStack(spacing: 20) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color("VibrantGreen"))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Text("Culinary PathwaysFortune")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            }
            
            Spacer()
            
            // Welcome content
            VStack(spacing: 20) {
                Text(viewModel.currentStep.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.currentStep.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
            }
            
            Spacer()
            
            // Features highlight
            VStack(spacing: 15) {
                FeatureRow(icon: "book.fill", title: "Personalized Recipes", description: "Discover recipes tailored to your taste")
                FeatureRow(icon: "calendar", title: "Smart Meal Planning", description: "Plan your week with intelligent suggestions")
                FeatureRow(icon: "fork.knife", title: "Restaurant Discovery", description: "Find amazing restaurants near you")
                FeatureRow(icon: "timer", title: "Cooking Timers", description: "Built-in timers for perfect meals")
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Continue button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.nextStep()
                }
            }) {
                HStack {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(Color("PrimaryRed"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .padding(.top, 20)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("GoldenYellow"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(OnboardingViewModel())
        .background(
            LinearGradient(
                colors: [Color("PrimaryRed"), Color("WarmBeige")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
