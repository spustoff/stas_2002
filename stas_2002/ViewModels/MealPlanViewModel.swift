//
//  MealPlanViewModel.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import Combine

@MainActor
class MealPlanViewModel: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    @Published var currentMealPlan: MealPlan?
    @Published var shoppingLists: [ShoppingList] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataStore: DataStore
    private let recipeViewModel: RecipeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: DataStore = .shared, recipeViewModel: RecipeViewModel) {
        self.dataStore = dataStore
        self.recipeViewModel = recipeViewModel
        loadMealPlans()
    }
    
    var todaysMeals: DailyMeals? {
        guard let currentPlan = currentMealPlan else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        return currentPlan.meals.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    var upcomingMeals: [DailyMeals] {
        guard let currentPlan = currentMealPlan else { return [] }
        let today = Calendar.current.startOfDay(for: Date())
        return currentPlan.meals.filter { $0.date >= today }.sorted { $0.date < $1.date }
    }
    
    func loadMealPlans() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedPlans = try await dataStore.loadMealPlans()
                await MainActor.run {
                    self.mealPlans = loadedPlans
                    self.currentMealPlan = loadedPlans.first { plan in
                        let today = Date()
                        return plan.startDate <= today && plan.endDate >= today
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load meal plans: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func createMealPlan(
        name: String,
        description: String,
        startDate: Date,
        duration: Int,
        dietaryRestrictions: [MealPlan.DietaryRestriction]
    ) {
        isLoading = true
        
        Task {
            do {
                let endDate = Calendar.current.date(byAdding: .day, value: duration, to: startDate) ?? startDate
                let dailyMeals = generateDailyMeals(from: startDate, to: endDate, restrictions: dietaryRestrictions)
                let totalCalories = dailyMeals.reduce(0) { $0 + $1.totalCalories }
                
                let newPlan = MealPlan(
                    name: name,
                    description: description,
                    startDate: startDate,
                    endDate: endDate,
                    meals: dailyMeals,
                    totalCalories: totalCalories,
                    dietaryRestrictions: dietaryRestrictions,
                    createdDate: Date()
                )
                
                try await dataStore.saveMealPlan(newPlan)
                
                await MainActor.run {
                    self.mealPlans.append(newPlan)
                    if Calendar.current.isDate(startDate, inSameDayAs: Date()) {
                        self.currentMealPlan = newPlan
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to create meal plan: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    private func generateDailyMeals(
        from startDate: Date,
        to endDate: Date,
        restrictions: [MealPlan.DietaryRestriction]
    ) -> [DailyMeals] {
        var dailyMeals: [DailyMeals] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let meals = DailyMeals(
                date: currentDate,
                breakfast: generateMealEntry(for: .breakfast, restrictions: restrictions),
                lunch: generateMealEntry(for: .lunch, restrictions: restrictions),
                dinner: generateMealEntry(for: .dinner, restrictions: restrictions),
                snacks: [generateMealEntry(for: .snack, restrictions: restrictions)].compactMap { $0 }
            )
            
            dailyMeals.append(meals)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dailyMeals
    }
    
    private func generateMealEntry(
        for mealType: MealEntry.MealType,
        restrictions: [MealPlan.DietaryRestriction]
    ) -> MealEntry? {
        // Filter recipes based on dietary restrictions
        let availableRecipes = recipeViewModel.recipes.filter { recipe in
            // Simple filtering logic - in a real app, this would be more sophisticated
            if restrictions.contains(.vegetarian) && !recipe.tags.contains("vegetarian") {
                return false
            }
            if restrictions.contains(.vegan) && !recipe.tags.contains("vegan") {
                return false
            }
            if restrictions.contains(.glutenFree) && !recipe.tags.contains("gluten-free") {
                return false
            }
            return true
        }
        
        guard let randomRecipe = availableRecipes.randomElement() else {
            // Fallback to generic meal entries
            return generateGenericMealEntry(for: mealType)
        }
        
        let calories = randomRecipe.nutritionInfo?.calories ?? estimateCalories(for: mealType)
        
        return MealEntry(
            recipeId: randomRecipe.id,
            recipeName: randomRecipe.title,
            mealType: mealType,
            calories: calories,
            servings: 1.0,
            notes: nil
        )
    }
    
    private func generateGenericMealEntry(for mealType: MealEntry.MealType) -> MealEntry {
        let genericMeals: [MealEntry.MealType: (name: String, calories: Int)] = [
            .breakfast: ("Oatmeal with Fruits", 300),
            .lunch: ("Grilled Chicken Salad", 400),
            .dinner: ("Baked Salmon with Vegetables", 500),
            .snack: ("Greek Yogurt", 150)
        ]
        
        let meal = genericMeals[mealType] ?? ("Healthy Meal", 300)
        
        return MealEntry(
            recipeId: nil,
            recipeName: meal.name,
            mealType: mealType,
            calories: meal.calories,
            servings: 1.0,
            notes: nil
        )
    }
    
    private func estimateCalories(for mealType: MealEntry.MealType) -> Int {
        switch mealType {
        case .breakfast: return 300
        case .lunch: return 400
        case .dinner: return 500
        case .snack: return 150
        }
    }
    
    func updateMealEntry(_ mealEntry: MealEntry, in dailyMeals: DailyMeals) {
        guard let planIndex = mealPlans.firstIndex(where: { $0.id == currentMealPlan?.id }),
              let dayIndex = mealPlans[planIndex].meals.firstIndex(where: { $0.id == dailyMeals.id }) else {
            return
        }
        
        var updatedDailyMeals = mealPlans[planIndex].meals[dayIndex]
        
        switch mealEntry.mealType {
        case .breakfast:
            updatedDailyMeals = DailyMeals(
                date: updatedDailyMeals.date,
                breakfast: mealEntry,
                lunch: updatedDailyMeals.lunch,
                dinner: updatedDailyMeals.dinner,
                snacks: updatedDailyMeals.snacks
            )
        case .lunch:
            updatedDailyMeals = DailyMeals(
                date: updatedDailyMeals.date,
                breakfast: updatedDailyMeals.breakfast,
                lunch: mealEntry,
                dinner: updatedDailyMeals.dinner,
                snacks: updatedDailyMeals.snacks
            )
        case .dinner:
            updatedDailyMeals = DailyMeals(
                date: updatedDailyMeals.date,
                breakfast: updatedDailyMeals.breakfast,
                lunch: updatedDailyMeals.lunch,
                dinner: mealEntry,
                snacks: updatedDailyMeals.snacks
            )
        case .snack:
            // For snacks, replace the first snack or add if none exist
            var snacks = updatedDailyMeals.snacks
            if snacks.isEmpty {
                snacks.append(mealEntry)
            } else {
                snacks[0] = mealEntry
            }
            updatedDailyMeals = DailyMeals(
                date: updatedDailyMeals.date,
                breakfast: updatedDailyMeals.breakfast,
                lunch: updatedDailyMeals.lunch,
                dinner: updatedDailyMeals.dinner,
                snacks: snacks
            )
        }
        
        var updatedPlan = mealPlans[planIndex]
        updatedPlan.meals[dayIndex] = updatedDailyMeals
        mealPlans[planIndex] = updatedPlan
        
        // Update current meal plan if it's the active one
        if updatedPlan.id == currentMealPlan?.id {
            currentMealPlan = updatedPlan
        }
        
        // Save changes
        Task {
            try? await dataStore.saveMealPlan(mealPlans[planIndex])
        }
    }
    
    func generateShoppingList(for mealPlan: MealPlan) {
        Task {
            do {
                let items = extractShoppingItems(from: mealPlan)
                let shoppingList = ShoppingList(
                    mealPlanId: mealPlan.id,
                    items: items,
                    createdDate: Date(),
                    isCompleted: false
                )
                
                try await dataStore.saveShoppingList(shoppingList)
                
                await MainActor.run {
                    self.shoppingLists.append(shoppingList)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to generate shopping list: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func extractShoppingItems(from mealPlan: MealPlan) -> [ShoppingItem] {
        var ingredientCounts: [String: (quantity: String, category: ShoppingItem.ItemCategory)] = [:]
        
        for dailyMeal in mealPlan.meals {
            for meal in dailyMeal.allMeals {
                if let recipeId = meal.recipeId,
                   let recipe = recipeViewModel.getRecipeById(recipeId) {
                    for ingredient in recipe.ingredients {
                        let category = categorizeIngredient(ingredient)
                        if let existing = ingredientCounts[ingredient] {
                            // In a real app, you'd properly combine quantities
                            ingredientCounts[ingredient] = (quantity: existing.quantity, category: category)
                        } else {
                            ingredientCounts[ingredient] = (quantity: "1", category: category)
                        }
                    }
                }
            }
        }
        
        return ingredientCounts.map { ingredient, details in
            ShoppingItem(
                name: ingredient,
                quantity: details.quantity,
                category: details.category,
                isCompleted: false,
                estimatedPrice: nil
            )
        }.sorted { $0.category.rawValue < $1.category.rawValue }
    }
    
    private func categorizeIngredient(_ ingredient: String) -> ShoppingItem.ItemCategory {
        let lowercased = ingredient.lowercased()
        
        if lowercased.contains("chicken") || lowercased.contains("beef") || lowercased.contains("fish") || lowercased.contains("salmon") {
            return .meat
        } else if lowercased.contains("milk") || lowercased.contains("cheese") || lowercased.contains("yogurt") {
            return .dairy
        } else if lowercased.contains("tomato") || lowercased.contains("cucumber") || lowercased.contains("onion") || lowercased.contains("basil") {
            return .produce
        } else if lowercased.contains("bread") || lowercased.contains("bun") {
            return .bakery
        } else if lowercased.contains("frozen") {
            return .frozen
        } else {
            return .pantry
        }
    }
    
    func deleteMealPlan(_ mealPlan: MealPlan) {
        mealPlans.removeAll { $0.id == mealPlan.id }
        if currentMealPlan?.id == mealPlan.id {
            currentMealPlan = nil
        }
        
        Task {
            try? await dataStore.deleteMealPlan(mealPlan.id)
        }
    }
}
