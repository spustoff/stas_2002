//
//  APIService.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import CoreLocation

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://api.culinarypathwaysfortune.com/v1"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private init() {
        // Configure date formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
    }
    
    // MARK: - Generic Request Method
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decodedResponse = try decoder.decode(responseType, from: data)
            return decodedResponse
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
    }
    
    // MARK: - Recipe API
    
    func fetchRecipes(
        cuisine: String? = nil,
        difficulty: Recipe.DifficultyLevel? = nil,
        dietaryRestrictions: [UserProfile.DietaryPreference] = [],
        page: Int = 1,
        limit: Int = 20
    ) async throws -> RecipeResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let cuisine = cuisine {
            queryItems.append(URLQueryItem(name: "cuisine", value: cuisine))
        }
        
        if let difficulty = difficulty {
            queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
        }
        
        for restriction in dietaryRestrictions {
            queryItems.append(URLQueryItem(name: "dietary_restrictions", value: restriction.rawValue))
        }
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        let endpoint = "/recipes?\(queryString)"
        
        return try await performRequest(endpoint: endpoint, responseType: RecipeResponse.self)
    }
    
    func fetchRecipeDetails(id: UUID) async throws -> Recipe {
        let endpoint = "/recipes/\(id.uuidString)"
        return try await performRequest(endpoint: endpoint, responseType: Recipe.self)
    }
    
    func searchRecipes(query: String, page: Int = 1, limit: Int = 20) async throws -> RecipeResponse {
        let queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        let endpoint = "/recipes/search?\(queryString)"
        
        return try await performRequest(endpoint: endpoint, responseType: RecipeResponse.self)
    }
    
    // MARK: - Restaurant API
    
    func fetchRestaurants(
        location: CLLocationCoordinate2D,
        radius: Double = 5000, // meters
        cuisine: String? = nil,
        priceRange: Restaurant.PriceRange? = nil,
        features: [Restaurant.RestaurantFeature] = [],
        page: Int = 1,
        limit: Int = 20
    ) async throws -> RestaurantResponse {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lng", value: "\(location.longitude)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let cuisine = cuisine {
            queryItems.append(URLQueryItem(name: "cuisine", value: cuisine))
        }
        
        if let priceRange = priceRange {
            queryItems.append(URLQueryItem(name: "price_range", value: priceRange.rawValue))
        }
        
        for feature in features {
            queryItems.append(URLQueryItem(name: "features", value: feature.rawValue))
        }
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        let endpoint = "/restaurants?\(queryString)"
        
        return try await performRequest(endpoint: endpoint, responseType: RestaurantResponse.self)
    }
    
    func fetchRestaurantDetails(id: UUID) async throws -> Restaurant {
        let endpoint = "/restaurants/\(id.uuidString)"
        return try await performRequest(endpoint: endpoint, responseType: Restaurant.self)
    }
    
    // MARK: - Meal Plan API
    
    func generateMealPlan(
        preferences: MealPlanPreferences
    ) async throws -> MealPlan {
        let body = try encoder.encode(preferences)
        return try await performRequest(
            endpoint: "/meal-plans/generate",
            method: .POST,
            body: body,
            responseType: MealPlan.self
        )
    }
    
    func saveMealPlan(_ mealPlan: MealPlan) async throws -> MealPlan {
        let body = try encoder.encode(mealPlan)
        return try await performRequest(
            endpoint: "/meal-plans",
            method: .POST,
            body: body,
            responseType: MealPlan.self
        )
    }
    
    func fetchUserMealPlans() async throws -> [MealPlan] {
        let response = try await performRequest(
            endpoint: "/meal-plans",
            responseType: MealPlanListResponse.self
        )
        return response.mealPlans
    }
    
    // MARK: - User Profile API
    
    func saveUserProfile(_ profile: UserProfile) async throws -> UserProfile {
        let body = try encoder.encode(profile)
        return try await performRequest(
            endpoint: "/users/profile",
            method: .PUT,
            body: body,
            responseType: UserProfile.self
        )
    }
    
    func fetchUserProfile() async throws -> UserProfile {
        return try await performRequest(
            endpoint: "/users/profile",
            responseType: UserProfile.self
        )
    }
    
    // MARK: - Recommendations API
    
    func fetchPersonalizedRecipes(limit: Int = 10) async throws -> [Recipe] {
        let endpoint = "/recommendations/recipes?limit=\(limit)"
        let response = try await performRequest(endpoint: endpoint, responseType: RecipeResponse.self)
        return response.recipes
    }
    
    func fetchPersonalizedRestaurants(
        location: CLLocationCoordinate2D,
        limit: Int = 10
    ) async throws -> [Restaurant] {
        let endpoint = "/recommendations/restaurants?lat=\(location.latitude)&lng=\(location.longitude)&limit=\(limit)"
        let response = try await performRequest(endpoint: endpoint, responseType: RestaurantResponse.self)
        return response.restaurants
    }
}

// MARK: - Supporting Types

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case networkError(Error)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}

// MARK: - Response Models

struct RecipeResponse: Codable {
    let recipes: [Recipe]
    let totalCount: Int
    let page: Int
    let limit: Int
    let hasMore: Bool
}

struct RestaurantResponse: Codable {
    let restaurants: [Restaurant]
    let totalCount: Int
    let page: Int
    let limit: Int
    let hasMore: Bool
}

struct MealPlanListResponse: Codable {
    let mealPlans: [MealPlan]
    let totalCount: Int
}

struct MealPlanPreferences: Codable {
    let startDate: Date
    let duration: Int // days
    let dietaryRestrictions: [MealPlan.DietaryRestriction]
    let targetCalories: Int?
    let mealsPerDay: Int
    let excludeIngredients: [String]
    let preferredCuisines: [String]
}
