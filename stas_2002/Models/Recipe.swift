//
//  Recipe.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let ingredients: [String]
    let instructions: [String]
    let prepTime: Int // in minutes
    let cookTime: Int // in minutes
    let servings: Int
    let difficulty: DifficultyLevel
    let cuisine: String
    let imageURL: String?
    let nutritionInfo: NutritionInfo?
    let tags: [String]
    let isFavorite: Bool
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    var totalTime: Int {
        return prepTime + cookTime
    }
}

struct NutritionInfo: Codable {
    let calories: Int
    let protein: Double // in grams
    let carbs: Double // in grams
    let fat: Double // in grams
    let fiber: Double // in grams
}

// Sample data for development
extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            title: "Mediterranean Quinoa Bowl",
            description: "A healthy and delicious quinoa bowl with fresh vegetables and Mediterranean flavors.",
            ingredients: [
                "1 cup quinoa",
                "2 cups vegetable broth",
                "1 cucumber, diced",
                "2 tomatoes, chopped",
                "1/2 red onion, sliced",
                "1/4 cup kalamata olives",
                "1/4 cup feta cheese",
                "2 tbsp olive oil",
                "1 lemon, juiced",
                "Fresh herbs (parsley, mint)"
            ],
            instructions: [
                "Rinse quinoa and cook in vegetable broth for 15 minutes",
                "Let quinoa cool completely",
                "Dice cucumber and tomatoes",
                "Slice red onion thinly",
                "Mix olive oil and lemon juice for dressing",
                "Combine all ingredients in a large bowl",
                "Toss with dressing and serve"
            ],
            prepTime: 15,
            cookTime: 15,
            servings: 4,
            difficulty: .easy,
            cuisine: "Mediterranean",
            imageURL: nil,
            nutritionInfo: NutritionInfo(calories: 320, protein: 12.0, carbs: 45.0, fat: 11.0, fiber: 6.0),
            tags: ["healthy", "vegetarian", "gluten-free"],
            isFavorite: false
        ),
        Recipe(
            title: "Spicy Thai Basil Chicken",
            description: "Authentic Thai stir-fry with aromatic basil and bold flavors.",
            ingredients: [
                "1 lb ground chicken",
                "3 cloves garlic, minced",
                "2 Thai chilies, sliced",
                "1 cup fresh Thai basil",
                "2 tbsp vegetable oil",
                "2 tbsp fish sauce",
                "1 tbsp soy sauce",
                "1 tsp sugar",
                "Jasmine rice for serving"
            ],
            instructions: [
                "Heat oil in a wok over high heat",
                "Add garlic and chilies, stir-fry for 30 seconds",
                "Add ground chicken and cook until done",
                "Add fish sauce, soy sauce, and sugar",
                "Stir in fresh basil leaves",
                "Serve over jasmine rice"
            ],
            prepTime: 10,
            cookTime: 10,
            servings: 2,
            difficulty: .medium,
            cuisine: "Thai",
            imageURL: nil,
            nutritionInfo: NutritionInfo(calories: 450, protein: 35.0, carbs: 8.0, fat: 28.0, fiber: 2.0),
            tags: ["spicy", "asian", "quick"],
            isFavorite: true
        )
    ]
}
