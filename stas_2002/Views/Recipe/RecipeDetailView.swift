//
//  RecipeDetailView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel
    @State private var selectedTab: DetailTab = .ingredients
    
    enum DetailTab: String, CaseIterable {
        case ingredients = "Ingredients"
        case instructions = "Instructions"
        case nutrition = "Nutrition"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image with gradient
                ZStack {
                    LinearGradient(
                        colors: ImageHelpers.gradientColors(for: recipe.cuisine),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 250)
                    
                    // Decorative pattern
                    VStack {
                        HStack {
                            Image(systemName: ImageHelpers.cuisineIcon(for: recipe.cuisine))
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.3))
                            Spacer()
                            Image(systemName: "fork.knife")
                                .font(.system(size: 30, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.2))
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 25, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.2))
                            Spacer()
                            Image(systemName: ImageHelpers.cuisineIcon(for: recipe.cuisine))
                                .font(.system(size: 35, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(30)
                    
                    // Overlay with recipe info
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                
                                Text(recipe.cuisine)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.toggleFavorite(for: recipe)
                            }) {
                                Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(recipe.isFavorite ? Color("AccentRed") : .white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 44, height: 44)
                                    )
                            }
                        }
                        .padding(20)
                    }
                }
                
                // Recipe stats
                HStack(spacing: 20) {
                    StatItem(icon: "clock", value: "\(recipe.totalTime)", label: "minutes")
                    StatItem(icon: "person.2", value: "\(recipe.servings)", label: "servings")
                    StatItem(icon: "chart.bar", value: recipe.difficulty.rawValue, label: "difficulty")
                    
                    if let nutrition = recipe.nutritionInfo {
                        StatItem(icon: "flame", value: "\(nutrition.calories)", label: "calories")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                
                // Description
                if !recipe.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(recipe.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Tab selector
                HStack(spacing: 0) {
                    ForEach(DetailTab.allCases, id: \.self) { tab in
                        Button(action: { selectedTab = tab }) {
                            Text(tab.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedTab == tab ? Color("VibrantGreen") : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color("VibrantGreen").opacity(0.1) : Color.clear)
                                )
                        }
                    }
                }
                .background(Color(.systemGray6))
                
                // Tab content
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedTab {
                    case .ingredients:
                        IngredientsView(ingredients: recipe.ingredients)
                    case .instructions:
                        InstructionsView(instructions: recipe.instructions)
                    case .nutrition:
                        if let nutrition = recipe.nutritionInfo {
                            NutritionView(nutrition: nutrition)
                        } else {
                            Text("Nutrition information not available")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Tags
                if !recipe.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        FlowLayout(items: recipe.tags, spacing: 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Menu {
                Button(action: {}) {
                    Label("Share Recipe", systemImage: "square.and.arrow.up")
                }
                
                Button(action: {}) {
                    Label("Add to Meal Plan", systemImage: "calendar.badge.plus")
                }
                
                Button(action: {}) {
                    Label("Start Cooking Timer", systemImage: "timer")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(Color("VibrantGreen"))
            }
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("VibrantGreen"))
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IngredientsView: View {
    let ingredients: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color("VibrantGreen"))
                        .frame(width: 24, alignment: .leading)
                    
                    Text(ingredient)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                
                if index < ingredients.count - 1 {
                    Divider()
                }
            }
        }
    }
}

struct InstructionsView: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color("VibrantGreen"))
                            .frame(width: 28, height: 28)
                        
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text(instruction)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct NutritionView: View {
    let nutrition: NutritionInfo
    
    var body: some View {
        VStack(spacing: 16) {
            // Calories highlight
            VStack(spacing: 4) {
                Text("\(nutrition.calories)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("VibrantGreen"))
                
                Text("Calories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("VibrantGreen").opacity(0.1))
            .cornerRadius(12)
            
            // Macronutrients
            VStack(spacing: 12) {
                NutritionRow(label: "Protein", value: "\(Int(nutrition.protein))g", color: Color("AccentRed"))
                NutritionRow(label: "Carbohydrates", value: "\(Int(nutrition.carbs))g", color: Color("GoldenYellow"))
                NutritionRow(label: "Fat", value: "\(Int(nutrition.fat))g", color: Color("PrimaryRed"))
                NutritionRow(label: "Fiber", value: "\(Int(nutrition.fiber))g", color: Color("VibrantGreen"))
            }
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

// iOS 15.6 compatible flow layout using LazyVGrid
struct FlowLayout: View {
    let items: [String]
    let spacing: CGFloat
    
    init(items: [String], spacing: CGFloat = 8) {
        self.items = items
        self.spacing = spacing
    }
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: spacing) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("GoldenYellow").opacity(0.2))
                    .cornerRadius(12)
            }
        }
    }
    
}

#Preview {
    NavigationView {
        RecipeDetailView(recipe: Recipe.sampleRecipes[0])
            .environmentObject(RecipeViewModel())
    }
}
