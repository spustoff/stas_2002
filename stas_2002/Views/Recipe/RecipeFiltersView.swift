//
//  RecipeFiltersView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct RecipeFiltersView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Cuisine filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Cuisine")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.cuisines, id: \.self) { cuisine in
                                FilterChip(
                                    title: cuisine,
                                    isSelected: viewModel.selectedCuisine == cuisine
                                ) {
                                    viewModel.selectedCuisine = cuisine
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Difficulty filter
                VStack(alignment: .leading, spacing: 12) {
                    Text("Difficulty")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        FilterChip(
                            title: "All",
                            isSelected: viewModel.selectedDifficulty == nil
                        ) {
                            viewModel.selectedDifficulty = nil
                        }
                        
                        ForEach(Recipe.DifficultyLevel.allCases, id: \.self) { difficulty in
                            FilterChip(
                                title: difficulty.rawValue,
                                isSelected: viewModel.selectedDifficulty == difficulty
                            ) {
                                viewModel.selectedDifficulty = difficulty
                            }
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button("Apply Filters") {
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding()
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color("VibrantGreen"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("VibrantGreen") : Color("VibrantGreen").opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("VibrantGreen"), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color("VibrantGreen"))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(Color("VibrantGreen"))
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color("VibrantGreen").opacity(0.1))
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color("VibrantGreen"), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    RecipeFiltersView()
        .environmentObject(RecipeViewModel())
}
