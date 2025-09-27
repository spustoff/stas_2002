//
//  PreferencesView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var selectedDietaryPreferences: Set<UserProfile.DietaryPreference> = []
    @State private var selectedAllergies: Set<UserProfile.Allergy> = []
    @State private var selectedCuisines: Set<String> = []
    @State private var skillLevel: UserProfile.CookingSkillLevel = .beginner
    
    let cuisines = ["Italian", "Mediterranean", "Asian", "Mexican", "Indian", "French", "American", "Thai", "Japanese"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Text(viewModel.currentStep.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentStep.description)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Preferences sections
                VStack(spacing: 20) {
                    
                    // Cooking Skill Level
                    PreferenceSection(title: "Cooking Experience") {
                        VStack(spacing: 10) {
                            ForEach(UserProfile.CookingSkillLevel.allCases, id: \.self) { level in
                                SkillLevelRow(
                                    level: level,
                                    isSelected: skillLevel == level
                                ) {
                                    skillLevel = level
                                }
                            }
                        }
                    }
                    
                    // Dietary Preferences
                    PreferenceSection(title: "Dietary Preferences") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(UserProfile.DietaryPreference.allCases, id: \.self) { preference in
                                PreferenceChip(
                                    title: preference.rawValue,
                                    isSelected: selectedDietaryPreferences.contains(preference)
                                ) {
                                    if selectedDietaryPreferences.contains(preference) {
                                        selectedDietaryPreferences.remove(preference)
                                    } else {
                                        selectedDietaryPreferences.insert(preference)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Allergies
                    PreferenceSection(title: "Allergies") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(UserProfile.Allergy.allCases, id: \.self) { allergy in
                                PreferenceChip(
                                    title: allergy.rawValue,
                                    isSelected: selectedAllergies.contains(allergy)
                                ) {
                                    if selectedAllergies.contains(allergy) {
                                        selectedAllergies.remove(allergy)
                                    } else {
                                        selectedAllergies.insert(allergy)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Cuisine Preferences
                    PreferenceSection(title: "Favorite Cuisines") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                PreferenceChip(
                                    title: cuisine,
                                    isSelected: selectedCuisines.contains(cuisine)
                                ) {
                                    if selectedCuisines.contains(cuisine) {
                                        selectedCuisines.remove(cuisine)
                                    } else {
                                        selectedCuisines.insert(cuisine)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Navigation buttons
                HStack(spacing: 15) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.previousStep()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .foregroundColor(Color("PrimaryRed"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(25)
                    }
                    
                    Button(action: {
                        updateViewModel()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.nextStep()
                        }
                    }) {
                        HStack {
                            Text("Continue")
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.canProceed ? Color("VibrantGreen") : Color.gray)
                        .cornerRadius(25)
                    }
                    .disabled(!viewModel.canProceed)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            loadCurrentValues()
        }
    }
    
    private func loadCurrentValues() {
        selectedDietaryPreferences = Set(viewModel.userProfile.dietaryPreferences)
        selectedAllergies = Set(viewModel.userProfile.allergies)
        selectedCuisines = Set(viewModel.userProfile.cuisinePreferences)
        skillLevel = viewModel.userProfile.skillLevel
    }
    
    private func updateViewModel() {
        viewModel.updateDietaryPreferences(Array(selectedDietaryPreferences))
        viewModel.updateAllergies(Array(selectedAllergies))
        viewModel.updateCuisinePreferences(Array(selectedCuisines))
        viewModel.updateSkillLevel(skillLevel)
    }
}

struct PreferenceSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}

struct PreferenceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color("PrimaryRed") : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.white.opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SkillLevelRow: View {
    let level: UserProfile.CookingSkillLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color("VibrantGreen") : .white.opacity(0.6))
                
                Text(level.rawValue)
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PreferencesView()
        .environmentObject(OnboardingViewModel())
        .background(
            LinearGradient(
                colors: [Color("PrimaryRed"), Color("WarmBeige")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
