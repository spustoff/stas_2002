//
//  SettingsView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataStore = DataStore.shared
    @State private var showingProfile = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile section
                Section {
                    Button(action: { showingProfile = true }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("VibrantGreen"))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("User Profile")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Manage your preferences")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Preferences section
                Section("Preferences") {
                    SettingsRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        color: Color("PrimaryRed")
                    ) {
                        Toggle("", isOn: Binding(
                            get: { dataStore.userProfile?.preferences.isDarkModeEnabled ?? false },
                            set: { newValue in
                                if var profile = dataStore.userProfile {
                                    profile.preferences.isDarkModeEnabled = newValue
                                    Task {
                                        try? await dataStore.updateUserProfile(profile)
                                    }
                                }
                            }
                        ))
                        .labelsHidden()
                    }
                    
                    NavigationLink(destination: MeasurementSettingsView()) {
                        SettingsRow(
                            icon: "ruler.fill",
                            title: "Measurement Units",
                            color: Color("VibrantGreen")
                        ) {
                            Text(dataStore.userProfile?.preferences.measurementUnit.rawValue ?? "Imperial")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Data section
                Section("Data & Privacy") {
                    NavigationLink(destination: FavoritesView()) {
                        SettingsRow(
                            icon: "heart.fill",
                            title: "Favorites",
                            color: Color("AccentRed")
                        ) {
                            EmptyView()
                        }
                    }
                    
                    Button(action: syncData) {
                        SettingsRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Sync Data",
                            color: Color("VibrantGreen")
                        ) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: clearCache) {
                        SettingsRow(
                            icon: "trash.fill",
                            title: "Clear Cache",
                            color: Color("GoldenYellow")
                        ) {
                            Text(dataStore.getCacheSize())
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Support section
                Section("Support") {
                    Button(action: { showingAbout = true }) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "About",
                            color: Color("PrimaryRed")
                        ) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Account section
                Section("Account") {
                    Button(action: signOut) {
                        SettingsRow(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Sign Out",
                            color: Color("AccentRed")
                        ) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileEditView()
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func syncData() {
        Task {
            try? await dataStore.syncData()
        }
    }
    
    private func clearCache() {
        dataStore.clearCache()
    }
    
    private func sendFeedback() {
        if let url = URL(string: "mailto:support@culinarypathwaysfortune.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        // In a real app, this would open the App Store rating page
    }
    
    private func signOut() {
        dataStore.clearAllData()
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    let content: Content
    
    init(icon: String, title: String, color: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            content
        }
        .padding(.vertical, 2)
    }
}

struct MeasurementSettingsView: View {
    @StateObject private var dataStore = DataStore.shared
    
    var body: some View {
        List {
            ForEach(AppPreferences.MeasurementUnit.allCases, id: \.self) { unit in
                HStack {
                    Text(unit.rawValue)
                    
                    Spacer()
                    
                    if dataStore.userProfile?.preferences.measurementUnit == unit {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color("VibrantGreen"))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if var profile = dataStore.userProfile {
                        profile.preferences.measurementUnit = unit
                        Task {
                            try? await dataStore.updateUserProfile(profile)
                        }
                    }
                }
            }
        }
        .navigationTitle("Measurement Units")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FavoritesView: View {
    var body: some View {
        List {
            Section("Favorite Recipes") {
                Text("No favorite recipes yet")
                    .foregroundColor(.secondary)
            }
            
            Section("Favorite Restaurants") {
                Text("No favorite restaurants yet")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileEditView: View {
    @StateObject private var dataStore = DataStore.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Dietary Preferences") {
                    Text("Manage your dietary preferences and allergies")
                        .foregroundColor(.secondary)
                }
                
                Section("Cooking Experience") {
                    Text("Update your cooking skill level")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveProfile()
                    dismiss()
                }
            )
        }
        .onAppear {
            loadProfile()
        }
    }
    
    private func loadProfile() {
        // Profile loading logic if needed
    }
    
    private func saveProfile() {
        // Profile saving logic if needed
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // App icon
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color("VibrantGreen"))
                
                VStack(spacing: 8) {
                    Text("Culinary PathwaysFortune")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("Discover personalized recipes, plan your meals, and explore amazing restaurants tailored just for you.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Made with ❤️ for food lovers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 Culinary PathwaysFortune")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    SettingsView()
}
