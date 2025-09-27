//
//  Restaurant.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let cuisine: String
    let address: String
    let phoneNumber: String?
    let website: String?
    let rating: Double
    let priceRange: PriceRange
    let imageURL: String?
    let latitude: Double
    let longitude: Double
    let openingHours: [DaySchedule]
    let features: [RestaurantFeature]
    let isFavorite: Bool
    
    enum PriceRange: String, CaseIterable, Codable {
        case budget = "$"
        case moderate = "$$"
        case expensive = "$$$"
        case luxury = "$$$$"
    }
    
    enum RestaurantFeature: String, CaseIterable, Codable {
        case delivery = "Delivery"
        case takeout = "Takeout"
        case dineIn = "Dine-in"
        case outdoor = "Outdoor Seating"
        case parking = "Parking Available"
        case wifi = "Free WiFi"
        case petFriendly = "Pet Friendly"
        case vegetarian = "Vegetarian Options"
        case vegan = "Vegan Options"
        case glutenFree = "Gluten-Free Options"
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
}

struct DaySchedule: Codable {
    let day: Weekday
    let openTime: String?
    let closeTime: String?
    let isClosed: Bool
    
    enum Weekday: String, CaseIterable, Codable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
    
    var displayText: String {
        if isClosed {
            return "Closed"
        } else if let open = openTime, let close = closeTime {
            return "\(open) - \(close)"
        } else {
            return "Hours not available"
        }
    }
}

// Sample data for development
extension Restaurant {
    static let sampleRestaurants: [Restaurant] = [
        Restaurant(
            name: "Bella Vista Italian",
            description: "Authentic Italian cuisine with a modern twist, featuring fresh pasta and wood-fired pizzas.",
            cuisine: "Italian",
            address: "123 Main Street, Downtown",
            phoneNumber: "(555) 123-4567",
            website: "https://bellavista.com",
            rating: 4.5,
            priceRange: .moderate,
            imageURL: nil,
            latitude: 37.7749,
            longitude: -122.4194,
            openingHours: [
                DaySchedule(day: .monday, openTime: "11:00 AM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .tuesday, openTime: "11:00 AM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .wednesday, openTime: "11:00 AM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .thursday, openTime: "11:00 AM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .friday, openTime: "11:00 AM", closeTime: "11:00 PM", isClosed: false),
                DaySchedule(day: .saturday, openTime: "11:00 AM", closeTime: "11:00 PM", isClosed: false),
                DaySchedule(day: .sunday, openTime: "12:00 PM", closeTime: "9:00 PM", isClosed: false)
            ],
            features: [.dineIn, .takeout, .delivery, .outdoor, .vegetarian],
            isFavorite: false
        ),
        Restaurant(
            name: "Sakura Sushi Bar",
            description: "Fresh sushi and traditional Japanese dishes in an elegant setting.",
            cuisine: "Japanese",
            address: "456 Oak Avenue, Midtown",
            phoneNumber: "(555) 987-6543",
            website: "https://sakurasushi.com",
            rating: 4.8,
            priceRange: .expensive,
            imageURL: nil,
            latitude: 37.7849,
            longitude: -122.4094,
            openingHours: [
                DaySchedule(day: .monday, openTime: nil, closeTime: nil, isClosed: true),
                DaySchedule(day: .tuesday, openTime: "5:00 PM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .wednesday, openTime: "5:00 PM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .thursday, openTime: "5:00 PM", closeTime: "10:00 PM", isClosed: false),
                DaySchedule(day: .friday, openTime: "5:00 PM", closeTime: "11:00 PM", isClosed: false),
                DaySchedule(day: .saturday, openTime: "5:00 PM", closeTime: "11:00 PM", isClosed: false),
                DaySchedule(day: .sunday, openTime: "5:00 PM", closeTime: "9:00 PM", isClosed: false)
            ],
            features: [.dineIn, .takeout, .parking, .glutenFree],
            isFavorite: true
        )
    ]
}
