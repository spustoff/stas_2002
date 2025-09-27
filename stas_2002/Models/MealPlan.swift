//
//  MealPlan.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    var meals: [DailyMeals]
    let totalCalories: Int
    let dietaryRestrictions: [DietaryRestriction]
    let createdDate: Date
    
    enum DietaryRestriction: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten-Free"
        case dairyFree = "Dairy-Free"
        case lowCarb = "Low Carb"
        case keto = "Keto"
        case paleo = "Paleo"
        case mediterranean = "Mediterranean"
    }
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var averageCaloriesPerDay: Int {
        guard duration > 0 else { return 0 }
        return totalCalories / duration
    }
}

struct DailyMeals: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let breakfast: MealEntry?
    let lunch: MealEntry?
    let dinner: MealEntry?
    let snacks: [MealEntry]
    
    var totalCalories: Int {
        let breakfastCal = breakfast?.calories ?? 0
        let lunchCal = lunch?.calories ?? 0
        let dinnerCal = dinner?.calories ?? 0
        let snacksCal = snacks.reduce(0) { $0 + $1.calories }
        return breakfastCal + lunchCal + dinnerCal + snacksCal
    }
    
    var allMeals: [MealEntry] {
        var meals: [MealEntry] = []
        if let breakfast = breakfast { meals.append(breakfast) }
        if let lunch = lunch { meals.append(lunch) }
        if let dinner = dinner { meals.append(dinner) }
        meals.append(contentsOf: snacks)
        return meals
    }
}

struct MealEntry: Identifiable, Codable {
    let id = UUID()
    let recipeId: UUID?
    let recipeName: String
    let mealType: MealType
    let calories: Int
    let servings: Double
    let notes: String?
    
    enum MealType: String, CaseIterable, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
}

struct ShoppingList: Identifiable, Codable {
    let id = UUID()
    let mealPlanId: UUID
    let items: [ShoppingItem]
    let createdDate: Date
    let isCompleted: Bool
    
    var completedItems: [ShoppingItem] {
        items.filter { $0.isCompleted }
    }
    
    var pendingItems: [ShoppingItem] {
        items.filter { !$0.isCompleted }
    }
    
    var completionPercentage: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedItems.count) / Double(items.count) * 100
    }
}

struct ShoppingItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let quantity: String
    let category: ItemCategory
    let isCompleted: Bool
    let estimatedPrice: Double?
    
    enum ItemCategory: String, CaseIterable, Codable {
        case produce = "Produce"
        case meat = "Meat & Seafood"
        case dairy = "Dairy"
        case pantry = "Pantry"
        case frozen = "Frozen"
        case bakery = "Bakery"
        case beverages = "Beverages"
        case other = "Other"
    }
}

// Sample data for development
extension MealPlan {
    static let sampleMealPlan: MealPlan = {
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        let dailyMeals = (0..<7).map { dayOffset in
            let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)!
            return DailyMeals(
                date: date,
                breakfast: MealEntry(
                    recipeId: nil,
                    recipeName: "Greek Yogurt with Berries",
                    mealType: .breakfast,
                    calories: 250,
                    servings: 1.0,
                    notes: nil
                ),
                lunch: MealEntry(
                    recipeId: nil,
                    recipeName: "Mediterranean Quinoa Bowl",
                    mealType: .lunch,
                    calories: 320,
                    servings: 1.0,
                    notes: "Extra feta cheese"
                ),
                dinner: MealEntry(
                    recipeId: nil,
                    recipeName: "Grilled Salmon with Vegetables",
                    mealType: .dinner,
                    calories: 450,
                    servings: 1.0,
                    notes: nil
                ),
                snacks: [
                    MealEntry(
                        recipeId: nil,
                        recipeName: "Mixed Nuts",
                        mealType: .snack,
                        calories: 180,
                        servings: 1.0,
                        notes: nil
                    )
                ]
            )
        }
        
        return MealPlan(
            name: "Healthy Mediterranean Week",
            description: "A balanced 7-day meal plan focusing on Mediterranean diet principles with fresh ingredients and wholesome meals.",
            startDate: startDate,
            endDate: endDate,
            meals: dailyMeals,
            totalCalories: 8400, // 1200 calories per day
            dietaryRestrictions: [.mediterranean, .glutenFree],
            createdDate: Date()
        )
    }()
}
