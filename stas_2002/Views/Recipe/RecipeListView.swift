//
//  RecipeListView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @State private var showingFilters = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Filter and sort bar
            HStack {
                Button(action: { showingFilters.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                        Text("Filters")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("VibrantGreen"))
                }
                
                Spacer()
                
                if !viewModel.searchText.isEmpty || viewModel.selectedCuisine != "All" || viewModel.selectedDifficulty != nil {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("AccentRed"))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Recipe list
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading recipes...")
                    .foregroundColor(Color("PrimaryRed"))
                Spacer()
            } else if viewModel.filteredRecipes.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "book.closed",
                    title: "No Recipes Found",
                    message: "Try adjusting your search or filters"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredRecipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                RecipeCard(recipe: recipe) {
                                    viewModel.toggleFavorite(for: recipe)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingFilters) {
            RecipeFiltersView()
                .environmentObject(viewModel)
        }
        .refreshable {
            viewModel.refreshRecipes()
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe image with gradient background
            ZStack {
                // Dynamic gradient based on cuisine
                LinearGradient(
                    colors: ImageHelpers.gradientColors(for: recipe.cuisine),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 180)
                
                // Cuisine-specific icon
                Image(systemName: ImageHelpers.cuisineIcon(for: recipe.cuisine))
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                
                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onFavoriteToggle) {
                            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(recipe.isFavorite ? Color("AccentRed") : .white)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 36, height: 36)
                                )
                        }
                        .padding(12)
                    }
                    Spacer()
                }
                
                // Difficulty badge
                VStack {
                    Spacer()
                    HStack {
                        DifficultyBadge(difficulty: recipe.difficulty)
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Recipe info
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(recipe.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(recipe.totalTime) min", systemImage: "clock")
                    Spacer()
                    Label("\(recipe.servings)", systemImage: "person.2")
                    Spacer()
                    Text(recipe.cuisine)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("GoldenYellow").opacity(0.2))
                        .cornerRadius(8)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


struct DifficultyBadge: View {
    let difficulty: Recipe.DifficultyLevel
    
    var color: Color {
        switch difficulty {
        case .easy: return Color("VibrantGreen")
        case .medium: return Color("GoldenYellow")
        case .hard: return Color("AccentRed")
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search recipes...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

// Extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NavigationView {
        RecipeListView()
            .environmentObject(RecipeViewModel())
    }
}
