//
//  OnboardingViewModel.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userProfile: UserProfile
    @Published var isCompleted: Bool = false
    
    private let dataStore: DataStore
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case preferences = 1
        case finalization = 2
        
        var title: String {
            switch self {
            case .welcome:
                return "Welcome"
            case .preferences:
                return "Tell us about your preferences"
            case .finalization:
                return "You're all set!"
            }
        }
        
        var description: String {
            switch self {
            case .welcome:
                return "Discover personalized recipes, plan your meals, and explore amazing restaurants tailored just for you."
            case .preferences:
                return "Help us personalize your culinary journey by sharing your dietary preferences and cooking experience."
            case .finalization:
                return "Your profile is ready! Start exploring recipes and restaurants that match your taste."
            }
        }
    }
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
        self.userProfile = UserProfile(
            name: "User",
            email: "",
            profileImageURL: nil,
            dietaryPreferences: [],
            allergies: [],
            cuisinePreferences: [],
            skillLevel: .beginner,
            favoriteRecipeIds: Set<UUID>(),
            favoriteRestaurantIds: Set<UUID>(),
            nutritionGoals: nil,
            location: nil,
            preferences: AppPreferences(
                isDarkModeEnabled: false,
                notificationsEnabled: true,
                mealReminderTime: nil,
                shoppingListReminders: true,
                recipeRecommendationFrequency: .weekly,
                measurementUnit: .imperial,
                language: "en"
            ),
            createdDate: Date(),
            lastActiveDate: Date()
        )
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .preferences:
            return true
        case .finalization:
            return true
        }
    }
    
    var progressPercentage: Double {
        let totalSteps = OnboardingStep.allCases.count
        let currentStepIndex = currentStep.rawValue + 1
        return Double(currentStepIndex) / Double(totalSteps)
    }
    
    func nextStep() {
        guard canProceed else { return }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        } else {
            completeOnboarding()
        }
    }
    
    func previousStep() {
        if let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    func skipToStep(_ step: OnboardingStep) {
        currentStep = step
    }
    
    func completeOnboarding() {
        Task {
            do {
                try await dataStore.saveUserProfile(userProfile)
                await MainActor.run {
                    self.isCompleted = true
                }
            } catch {
                // Handle error - in a real app, you'd show an error message
                print("Failed to save user profile: \(error)")
            }
        }
    }
    
    // MARK: - Profile Updates
    
    func updateDietaryPreferences(_ preferences: [UserProfile.DietaryPreference]) {
        userProfile.dietaryPreferences = preferences
    }
    
    func updateAllergies(_ allergies: [UserProfile.Allergy]) {
        userProfile.allergies = allergies
    }
    
    func updateCuisinePreferences(_ cuisines: [String]) {
        userProfile.cuisinePreferences = cuisines
    }
    
    func updateSkillLevel(_ skillLevel: UserProfile.CookingSkillLevel) {
        userProfile.skillLevel = skillLevel
    }
    
    func updateNutritionGoals(_ goals: NutritionGoals?) {
        userProfile.nutritionGoals = goals
    }
    
    func updateAppPreferences(_ preferences: AppPreferences) {
        userProfile.preferences = preferences
    }
    
    // MARK: - Validation
    // Validation methods removed as basic info is no longer collected
    
    // MARK: - Convenience Methods
    
    func toggleDietaryPreference(_ preference: UserProfile.DietaryPreference) {
        if userProfile.dietaryPreferences.contains(preference) {
            userProfile.dietaryPreferences.removeAll { $0 == preference }
        } else {
            userProfile.dietaryPreferences.append(preference)
        }
    }
    
    func toggleAllergy(_ allergy: UserProfile.Allergy) {
        if userProfile.allergies.contains(allergy) {
            userProfile.allergies.removeAll { $0 == allergy }
        } else {
            userProfile.allergies.append(allergy)
        }
    }
    
    func toggleCuisinePreference(_ cuisine: String) {
        if userProfile.cuisinePreferences.contains(cuisine) {
            userProfile.cuisinePreferences.removeAll { $0 == cuisine }
        } else {
            userProfile.cuisinePreferences.append(cuisine)
        }
    }
    
    func resetOnboarding() {
        currentStep = .welcome
        isCompleted = false
        userProfile = UserProfile(
            name: "User",
            email: "",
            profileImageURL: nil,
            dietaryPreferences: [],
            allergies: [],
            cuisinePreferences: [],
            skillLevel: .beginner,
            favoriteRecipeIds: Set<UUID>(),
            favoriteRestaurantIds: Set<UUID>(),
            nutritionGoals: nil,
            location: nil,
            preferences: AppPreferences(
                isDarkModeEnabled: false,
                notificationsEnabled: true,
                mealReminderTime: nil,
                shoppingListReminders: true,
                recipeRecommendationFrequency: .weekly,
                measurementUnit: .imperial,
                language: "en"
            ),
            createdDate: Date(),
            lastActiveDate: Date()
        )
    }
}
