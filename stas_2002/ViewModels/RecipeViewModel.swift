//
//  RecipeViewModel.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var favoriteRecipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var selectedCuisine: String = "All"
    @Published var selectedDifficulty: Recipe.DifficultyLevel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dataStore: DataStore
    private var cancellables = Set<AnyCancellable>()
    
    let cuisines = ["All", "Italian", "Mediterranean", "Thai", "Japanese", "Mexican", "Indian", "French", "American"]
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
        loadRecipes()
        setupSearchAndFilters()
    }
    
    var filteredRecipes: [Recipe] {
        var filtered = recipes
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.joined().localizedCaseInsensitiveContains(searchText) ||
                recipe.tags.joined().localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by cuisine
        if selectedCuisine != "All" {
            filtered = filtered.filter { $0.cuisine == selectedCuisine }
        }
        
        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        return filtered
    }
    
    private func setupSearchAndFilters() {
        // Debounce search to avoid excessive filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                // Trigger UI update through filteredRecipes computed property
            }
            .store(in: &cancellables)
    }
    
    func loadRecipes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedRecipes = try await dataStore.loadRecipes()
                await MainActor.run {
                    self.recipes = loadedRecipes
                    self.updateFavoriteRecipes()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load recipes: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func toggleFavorite(for recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = Recipe(
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
                isFavorite: !recipe.isFavorite
            )
            
            // Update user profile
            if recipe.isFavorite {
                dataStore.removeFavoriteRecipe(recipe.id)
            } else {
                dataStore.addFavoriteRecipe(recipe.id)
            }
            
            updateFavoriteRecipes()
        }
    }
    
    private func updateFavoriteRecipes() {
        favoriteRecipes = recipes.filter { $0.isFavorite }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCuisine = "All"
        selectedDifficulty = nil
    }
    
    func getRecipeById(_ id: UUID) -> Recipe? {
        return recipes.first { $0.id == id }
    }
    
    func getRecipesByIds(_ ids: [UUID]) -> [Recipe] {
        return recipes.filter { ids.contains($0.id) }
    }
    
    func refreshRecipes() {
        loadRecipes()
    }
}
