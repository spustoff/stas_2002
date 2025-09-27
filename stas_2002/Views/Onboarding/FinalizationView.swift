//
//  FinalizationView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct FinalizationView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color("VibrantGreen"))
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(viewModel.currentStep.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Profile summary
            VStack(spacing: 20) {
                Text("Your Profile Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                ProfileSummaryCard(profile: viewModel.userProfile)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Final message
            VStack(spacing: 15) {
                Text(viewModel.currentStep.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Text("Ready to start your culinary journey?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color("GoldenYellow"))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 15) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        viewModel.completeOnboarding()
                    }
                }) {
                    HStack {
                        Text("Start Exploring")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.headline)
                    }
                    .foregroundColor(Color("PrimaryRed"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.previousStep()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Edit")
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .padding(.top, 20)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ProfileSummaryCard: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(spacing: 15) {
            // User info
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color("GoldenYellow"))
                    Text("Your Profile")
                        .fontWeight(.medium)
                    Spacer()
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Preferences summary
            VStack(spacing: 8) {
                SummaryRow(
                    icon: "chef.hat.fill",
                    title: "Skill Level",
                    value: profile.skillLevel.rawValue
                )
                
                if !profile.dietaryPreferences.isEmpty {
                    SummaryRow(
                        icon: "leaf.fill",
                        title: "Dietary",
                        value: profile.dietaryPreferences.prefix(2).map { $0.rawValue }.joined(separator: ", ") +
                               (profile.dietaryPreferences.count > 2 ? " +\(profile.dietaryPreferences.count - 2)" : "")
                    )
                }
                
                if !profile.cuisinePreferences.isEmpty {
                    SummaryRow(
                        icon: "globe",
                        title: "Cuisines",
                        value: profile.cuisinePreferences.prefix(2).joined(separator: ", ") +
                               (profile.cuisinePreferences.count > 2 ? " +\(profile.cuisinePreferences.count - 2)" : "")
                    )
                }
                
                if !profile.allergies.isEmpty {
                    SummaryRow(
                        icon: "exclamationmark.triangle.fill",
                        title: "Allergies",
                        value: profile.allergies.prefix(2).map { $0.rawValue }.joined(separator: ", ") +
                               (profile.allergies.count > 2 ? " +\(profile.allergies.count - 2)" : "")
                    )
                }
            }
        }
        .foregroundColor(.white)
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color("GoldenYellow"))
                .frame(width: 20)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    FinalizationView()
        .environmentObject(OnboardingViewModel())
        .background(
            LinearGradient(
                colors: [Color("PrimaryRed"), Color("WarmBeige")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
