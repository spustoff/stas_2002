//
//  MealPlanView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct MealPlanView: View {
    @EnvironmentObject var viewModel: MealPlanViewModel
    @State private var showingCreatePlan = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading meal plans...")
                    .foregroundColor(Color("PrimaryRed"))
                Spacer()
            } else if let currentPlan = viewModel.currentMealPlan {
                ScrollView {
                    VStack(spacing: 20) {
                        // Current plan header
                        CurrentPlanHeader(mealPlan: currentPlan)
                        
                        // Today's meals
                        if let todaysMeals = viewModel.todaysMeals {
                            TodaysMealsSection(dailyMeals: todaysMeals)
                        }
                        
                        // Upcoming meals
                        UpcomingMealsSection(upcomingMeals: viewModel.upcomingMeals)
                        
                        // Quick actions
                        QuickActionsSection(mealPlan: currentPlan)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            } else {
                // No meal plan state
                Spacer()
                EmptyStateView(
                    icon: "calendar.badge.plus",
                    title: "No Active Meal Plan",
                    message: "Create your first meal plan to get personalized meal suggestions"
                )
                
                Button("Create Meal Plan") {
                    showingCreatePlan = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .navigationTitle("Meal Plans")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: 
            Button(action: { showingCreatePlan = true }) {
                Image(systemName: "plus")
                    .foregroundColor(Color("VibrantGreen"))
            }
        )
        .sheet(isPresented: $showingCreatePlan) {
            CreateMealPlanView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.loadMealPlans()
        }
    }
}

struct CurrentPlanHeader: View {
    let mealPlan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealPlan.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(mealPlan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(mealPlan.duration) days")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("VibrantGreen"))
                    
                    Text("\(mealPlan.averageCaloriesPerDay) cal/day")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            let progress = Double(Calendar.current.dateComponents([.day], from: mealPlan.startDate, to: Date()).day ?? 0) / Double(mealPlan.duration)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color("VibrantGreen"))
                }
                
                ProgressView(value: min(max(progress, 0), 1))
                    .progressViewStyle(LinearProgressViewStyle(tint: Color("VibrantGreen")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TodaysMealsSection: View {
    let dailyMeals: DailyMeals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Meals")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if let breakfast = dailyMeals.breakfast {
                    MealCard(meal: breakfast, mealType: "Breakfast", icon: "sun.max")
                }
                
                if let lunch = dailyMeals.lunch {
                    MealCard(meal: lunch, mealType: "Lunch", icon: "sun.haze")
                }
                
                if let dinner = dailyMeals.dinner {
                    MealCard(meal: dinner, mealType: "Dinner", icon: "moon")
                }
                
                ForEach(dailyMeals.snacks) { snack in
                    MealCard(meal: snack, mealType: "Snack", icon: "leaf")
                }
            }
            
            // Daily total
            HStack {
                Text("Daily Total")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(dailyMeals.totalCalories) calories")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("VibrantGreen"))
            }
            .padding(.top, 8)
        }
    }
}

struct MealCard: View {
    let meal: MealEntry
    let mealType: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("GoldenYellow"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(mealType)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(meal.recipeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if let notes = meal.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(meal.calories)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct UpcomingMealsSection: View {
    let upcomingMeals: [DailyMeals]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Days")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(upcomingMeals.prefix(7)) { dailyMeal in
                        UpcomingDayCard(dailyMeals: dailyMeal)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

struct UpcomingDayCard: View {
    let dailyMeals: DailyMeals
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 2) {
                Text(dayFormatter.string(from: dailyMeals.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(dateFormatter.string(from: dailyMeals.date))
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 4) {
                Text("\(dailyMeals.totalCalories)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("VibrantGreen"))
                
                Text("calories")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(dailyMeals.allMeals.count) meals")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct QuickActionsSection: View {
    let mealPlan: MealPlan
    @EnvironmentObject var viewModel: MealPlanViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "cart",
                    title: "Shopping List",
                    subtitle: "Generate list",
                    color: Color("VibrantGreen")
                ) {
                    viewModel.generateShoppingList(for: mealPlan)
                }
                
                QuickActionCard(
                    icon: "timer",
                    title: "Meal Timer",
                    subtitle: "Start cooking",
                    color: Color("GoldenYellow")
                ) {
                    // Start cooking timer
                }
                
                QuickActionCard(
                    icon: "square.and.arrow.up",
                    title: "Share Plan",
                    subtitle: "With friends",
                    color: Color("AccentRed")
                ) {
                    // Share meal plan
                }
            }
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CreateMealPlanView: View {
    @EnvironmentObject var viewModel: MealPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var duration = 7
    @State private var selectedRestrictions: Set<MealPlan.DietaryRestriction> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    TextField("Plan Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Stepper("Duration: \(duration) days", value: $duration, in: 1...30)
                }
                
                Section("Dietary Restrictions") {
                    ForEach(MealPlan.DietaryRestriction.allCases, id: \.self) { restriction in
                        HStack {
                            Text(restriction.rawValue)
                            Spacer()
                            if selectedRestrictions.contains(restriction) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color("VibrantGreen"))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedRestrictions.contains(restriction) {
                                selectedRestrictions.remove(restriction)
                            } else {
                                selectedRestrictions.insert(restriction)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Meal Plan")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    viewModel.createMealPlan(
                        name: name,
                        description: description,
                        startDate: startDate,
                        duration: duration,
                        dietaryRestrictions: Array(selectedRestrictions)
                    )
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    NavigationView {
        MealPlanView()
            .environmentObject(MealPlanViewModel(recipeViewModel: RecipeViewModel()))
    }
}
