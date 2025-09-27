//
//  UserProfile.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var profileImageURL: String?
    var dietaryPreferences: [DietaryPreference]
    var allergies: [Allergy]
    var cuisinePreferences: [String]
    var skillLevel: CookingSkillLevel
    var favoriteRecipeIds: Set<UUID>
    var favoriteRestaurantIds: Set<UUID>
    var nutritionGoals: NutritionGoals?
    var location: UserLocation?
    var preferences: AppPreferences
    var createdDate: Date
    var lastActiveDate: Date
    
    enum DietaryPreference: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case pescatarian = "Pescatarian"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case lowCarb = "Low Carb"
        case keto = "Keto"
        case paleo = "Paleo"
        case mediterranean = "Mediterranean"
        case lowSodium = "Low Sodium"
        case diabetic = "Diabetic Friendly"
    }
    
    enum Allergy: String, CaseIterable, Codable {
        case nuts = "Tree Nuts"
        case peanuts = "Peanuts"
        case shellfish = "Shellfish"
        case fish = "Fish"
        case eggs = "Eggs"
        case dairy = "Dairy"
        case soy = "Soy"
        case wheat = "Wheat"
        case sesame = "Sesame"
    }
    
    enum CookingSkillLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
    
    mutating func addFavoriteRecipe(_ recipeId: UUID) {
        favoriteRecipeIds.insert(recipeId)
    }
    
    mutating func removeFavoriteRecipe(_ recipeId: UUID) {
        favoriteRecipeIds.remove(recipeId)
    }
    
    mutating func addFavoriteRestaurant(_ restaurantId: UUID) {
        favoriteRestaurantIds.insert(restaurantId)
    }
    
    mutating func removeFavoriteRestaurant(_ restaurantId: UUID) {
        favoriteRestaurantIds.remove(restaurantId)
    }
    
    func isRecipeFavorite(_ recipeId: UUID) -> Bool {
        favoriteRecipeIds.contains(recipeId)
    }
    
    func isRestaurantFavorite(_ restaurantId: UUID) -> Bool {
        favoriteRestaurantIds.contains(restaurantId)
    }
}

struct NutritionGoals: Codable {
    let dailyCalories: Int
    let protein: Double // in grams
    let carbs: Double // in grams
    let fat: Double // in grams
    let fiber: Double // in grams
    let sodium: Double // in mg
    let sugar: Double // in grams
    
    var proteinCalories: Int {
        Int(protein * 4) // 4 calories per gram of protein
    }
    
    var carbCalories: Int {
        Int(carbs * 4) // 4 calories per gram of carbs
    }
    
    var fatCalories: Int {
        Int(fat * 9) // 9 calories per gram of fat
    }
}

struct UserLocation: Codable {
    let latitude: Double
    let longitude: Double
    let city: String?
    let state: String?
    let country: String?
    let lastUpdated: Date
}

struct AppPreferences: Codable {
    var isDarkModeEnabled: Bool
    var notificationsEnabled: Bool
    var mealReminderTime: Date?
    var shoppingListReminders: Bool
    var recipeRecommendationFrequency: RecommendationFrequency
    var measurementUnit: MeasurementUnit
    var language: String
    
    enum RecommendationFrequency: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case never = "Never"
    }
    
    enum MeasurementUnit: String, CaseIterable, Codable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
}

// Sample data for development
extension UserProfile {
    static let sampleProfile = UserProfile(
        name: "Alex Johnson",
        email: "alex.johnson@example.com",
        profileImageURL: nil,
        dietaryPreferences: [.vegetarian, .glutenFree],
        allergies: [.nuts],
        cuisinePreferences: ["Mediterranean", "Italian", "Asian", "Mexican"],
        skillLevel: .intermediate,
        favoriteRecipeIds: Set<UUID>(),
        favoriteRestaurantIds: Set<UUID>(),
        nutritionGoals: NutritionGoals(
            dailyCalories: 2000,
            protein: 150.0,
            carbs: 200.0,
            fat: 65.0,
            fiber: 25.0,
            sodium: 2300.0,
            sugar: 50.0
        ),
        location: UserLocation(
            latitude: 37.7749,
            longitude: -122.4194,
            city: "San Francisco",
            state: "CA",
            country: "USA",
            lastUpdated: Date()
        ),
        preferences: AppPreferences(
            isDarkModeEnabled: false,
            notificationsEnabled: true,
            mealReminderTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()),
            shoppingListReminders: true,
            recipeRecommendationFrequency: .weekly,
            measurementUnit: .imperial,
            language: "en"
        ),
        createdDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
        lastActiveDate: Date()
    )
}
