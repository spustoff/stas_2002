//
//  DataStore.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

@MainActor
class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var userProfile: UserProfile?
    @Published var isOnboardingCompleted: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let apiService = APIService.shared
    
    // UserDefaults keys
    private enum Keys {
        static let userProfile = "userProfile"
        static let onboardingCompleted = "onboardingCompleted"
        static let favoriteRecipes = "favoriteRecipes"
        static let favoriteRestaurants = "favoriteRestaurants"
    }
    
    private init() {
        loadUserProfile()
        loadOnboardingStatus()
    }
    
    // MARK: - User Profile Management
    
    func loadUserProfile() {
        if let data = userDefaults.data(forKey: Keys.userProfile),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        let data = try JSONEncoder().encode(profile)
        userDefaults.set(data, forKey: Keys.userProfile)
        userProfile = profile
        isOnboardingCompleted = true
        userDefaults.set(true, forKey: Keys.onboardingCompleted)
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        try await saveUserProfile(profile)
    }
    
    private func loadOnboardingStatus() {
        isOnboardingCompleted = userDefaults.bool(forKey: Keys.onboardingCompleted)
    }
    
    // MARK: - Recipe Management
    
    func loadRecipes() async throws -> [Recipe] {
        // In a real app, this would fetch from an API
        // For now, return sample data with favorite status
        var recipes = Recipe.sampleRecipes
        let favoriteIds = getFavoriteRecipeIds()
        
        recipes = recipes.map { recipe in
            Recipe(
                title: recipe.title,
                description: recipe.description,
                ingredients: recipe.ingredients,
                instructions: recipe.instructions,
                prepTime: recipe.prepTime,
                cookTime: recipe.cookTime,
                servings: recipe.servings,
                difficulty: recipe.difficulty,
                cuisine: recipe.cuisine,
                imageURL: recipe.imageURL,
                nutritionInfo: recipe.nutritionInfo,
                tags: recipe.tags,
                isFavorite: favoriteIds.contains(recipe.id)
            )
        }
        
        return recipes
    }
    
    func saveRecipe(_ recipe: Recipe) async throws {
        // In a real app, this would save to an API
        // For now, we'll just handle favorites locally
        if recipe.isFavorite {
            addFavoriteRecipe(recipe.id)
        } else {
            removeFavoriteRecipe(recipe.id)
        }
    }
    
    func addFavoriteRecipe(_ recipeId: UUID) {
        var favorites = getFavoriteRecipeIds()
        favorites.insert(recipeId)
        saveFavoriteRecipeIds(favorites)
        
        // Update user profile
        if var profile = userProfile {
            profile.addFavoriteRecipe(recipeId)
            Task {
                try? await updateUserProfile(profile)
            }
        }
    }
    
    func removeFavoriteRecipe(_ recipeId: UUID) {
        var favorites = getFavoriteRecipeIds()
        favorites.remove(recipeId)
        saveFavoriteRecipeIds(favorites)
        
        // Update user profile
        if var profile = userProfile {
            profile.removeFavoriteRecipe(recipeId)
            Task {
                try? await updateUserProfile(profile)
            }
        }
    }
    
    private func getFavoriteRecipeIds() -> Set<UUID> {
        if let data = userDefaults.data(forKey: Keys.favoriteRecipes),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            return ids
        }
        return Set<UUID>()
    }
    
    private func saveFavoriteRecipeIds(_ ids: Set<UUID>) {
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: Keys.favoriteRecipes)
        }
    }
    
    // MARK: - Restaurant Management
    
    func loadRestaurants() async throws -> [Restaurant] {
        // In a real app, this would fetch from an API based on user location
        // For now, return sample data with favorite status
        var restaurants = Restaurant.sampleRestaurants
        let favoriteIds = getFavoriteRestaurantIds()
        
        restaurants = restaurants.map { restaurant in
            Restaurant(
                name: restaurant.name,
                description: restaurant.description,
                cuisine: restaurant.cuisine,
                address: restaurant.address,
                phoneNumber: restaurant.phoneNumber,
                website: restaurant.website,
                rating: restaurant.rating,
                priceRange: restaurant.priceRange,
                imageURL: restaurant.imageURL,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                openingHours: restaurant.openingHours,
                features: restaurant.features,
                isFavorite: favoriteIds.contains(restaurant.id)
            )
        }
        
        return restaurants
    }
    
    func addFavoriteRestaurant(_ restaurantId: UUID) {
        var favorites = getFavoriteRestaurantIds()
        favorites.insert(restaurantId)
        saveFavoriteRestaurantIds(favorites)
        
        // Update user profile
        if var profile = userProfile {
            profile.addFavoriteRestaurant(restaurantId)
            Task {
                try? await updateUserProfile(profile)
            }
        }
    }
    
    func removeFavoriteRestaurant(_ restaurantId: UUID) {
        var favorites = getFavoriteRestaurantIds()
        favorites.remove(restaurantId)
        saveFavoriteRestaurantIds(favorites)
        
        // Update user profile
        if var profile = userProfile {
            profile.removeFavoriteRestaurant(restaurantId)
            Task {
                try? await updateUserProfile(profile)
            }
        }
    }
    
    private func getFavoriteRestaurantIds() -> Set<UUID> {
        if let data = userDefaults.data(forKey: Keys.favoriteRestaurants),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            return ids
        }
        return Set<UUID>()
    }
    
    private func saveFavoriteRestaurantIds(_ ids: Set<UUID>) {
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: Keys.favoriteRestaurants)
        }
    }
    
    // MARK: - Meal Plan Management
    
    func loadMealPlans() async throws -> [MealPlan] {
        // In a real app, this would fetch from an API
        // For now, return sample data
        return [MealPlan.sampleMealPlan]
    }
    
    func saveMealPlan(_ mealPlan: MealPlan) async throws {
        // In a real app, this would save to an API
        // For now, we'll just simulate success
    }
    
    func deleteMealPlan(_ mealPlanId: UUID) async throws {
        // In a real app, this would delete from an API
        // For now, we'll just simulate success
    }
    
    // MARK: - Shopping List Management
    
    func saveShoppingList(_ shoppingList: ShoppingList) async throws {
        // In a real app, this would save to an API
        // For now, we'll just simulate success
    }
    
    func updateShoppingListItem(_ item: ShoppingItem, in shoppingListId: UUID) async throws {
        // In a real app, this would update the item in an API
        // For now, we'll just simulate success
    }
    
    // MARK: - Data Synchronization
    
    func syncData() async throws {
        // In a real app, this would sync local data with the server
        // For now, we'll just simulate success
    }
    
    func clearAllData() {
        userDefaults.removeObject(forKey: Keys.userProfile)
        userDefaults.removeObject(forKey: Keys.onboardingCompleted)
        userDefaults.removeObject(forKey: Keys.favoriteRecipes)
        userDefaults.removeObject(forKey: Keys.favoriteRestaurants)
        
        userProfile = nil
        isOnboardingCompleted = false
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        // In a real app, this would clear cached images and data
        // For now, we'll just simulate success
    }
    
    func getCacheSize() -> String {
        // In a real app, this would calculate actual cache size
        return "2.5 MB"
    }
}
