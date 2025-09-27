//
//  RestaurantListView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject var viewModel: RestaurantViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Sort and filter bar
            HStack {
                Menu {
                    ForEach(RestaurantViewModel.SortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            viewModel.sortBy = option
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort: \(viewModel.sortBy.rawValue)")
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("VibrantGreen"))
                }
                
                Spacer()
                
                if !viewModel.searchText.isEmpty || viewModel.selectedCuisine != "All" {
                    Button("Clear") {
                        viewModel.clearFilters()
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("AccentRed"))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Restaurant list
            if viewModel.isLoading {
                Spacer()
                ProgressView("Finding restaurants...")
                    .foregroundColor(Color("PrimaryRed"))
                Spacer()
            } else if viewModel.filteredAndSortedRestaurants.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "fork.knife",
                    title: "No Restaurants Found",
                    message: "Try adjusting your search or location"
                )
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredAndSortedRestaurants) { restaurant in
                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurant, isFavorite: restaurant.isFavorite)) {
                                RestaurantCard(restaurant: restaurant) {
                                    viewModel.toggleFavorite(for: restaurant)
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
        .navigationTitle("Restaurants")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            viewModel.refreshRestaurants()
        }
    }
}

struct RestaurantCard: View {
    let restaurant: Restaurant
    let onFavoriteToggle: () -> Void
    @EnvironmentObject var viewModel: RestaurantViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Restaurant image with gradient background
            ZStack {
                // Dynamic gradient based on cuisine and rating
                LinearGradient(
                    colors: ImageHelpers.restaurantGradientColors(for: restaurant),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 160)
                
                // Restaurant-specific decorative elements
                VStack {
                    HStack {
                        Image(systemName: ImageHelpers.cuisineIcon(for: restaurant.cuisine))
                            .font(.system(size: 35, weight: .light))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 25, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white.opacity(0.4))
                        Spacer()
                        Image(systemName: ImageHelpers.cuisineIcon(for: restaurant.cuisine))
                            .font(.system(size: 30, weight: .ultraLight))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(20)
                
                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onFavoriteToggle) {
                            Image(systemName: restaurant.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(restaurant.isFavorite ? Color("AccentRed") : .white)
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
                
                // Price range badge
                VStack {
                    Spacer()
                    HStack {
                        Text(restaurant.priceRange.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("VibrantGreen"))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .cornerRadius(12, corners: [.topLeft, .topRight])
            
            // Restaurant info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(Color("GoldenYellow"))
                        Text(restaurant.formattedRating)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                Text(restaurant.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(restaurant.cuisine)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("GoldenYellow").opacity(0.2))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    if let distance = viewModel.distanceToRestaurant(restaurant) {
                        HStack(spacing: 2) {
                            Image(systemName: "location")
                                .font(.caption)
                            Text(distance)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    NavigationView {
        RestaurantListView()
            .environmentObject(RestaurantViewModel())
    }
}
