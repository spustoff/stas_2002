//
//  ImageHelpers.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct ImageHelpers {
    static func gradientColors(for cuisine: String) -> [Color] {
        switch cuisine.lowercased() {
        case "italian":
            return [Color("AccentRed"), Color("GoldenYellow")]
        case "mediterranean":
            return [Color("VibrantGreen"), Color("WarmBeige")]
        case "thai", "asian":
            return [Color("GoldenYellow"), Color("AccentRed")]
        case "japanese":
            return [Color("PrimaryRed"), Color("WarmBeige")]
        case "mexican":
            return [Color("AccentRed"), Color("GoldenYellow")]
        case "indian":
            return [Color("GoldenYellow"), Color("VibrantGreen")]
        case "french":
            return [Color("WarmBeige"), Color("PrimaryRed")]
        case "american":
            return [Color("PrimaryRed"), Color("VibrantGreen")]
        case "chinese":
            return [Color("AccentRed"), Color("GoldenYellow")]
        default:
            return [Color("VibrantGreen"), Color("GoldenYellow")]
        }
    }
    
    static func cuisineIcon(for cuisine: String) -> String {
        switch cuisine.lowercased() {
        case "italian":
            return "leaf.fill"
        case "mediterranean":
            return "sun.max.fill"
        case "thai", "asian":
            return "flame.fill"
        case "japanese":
            return "drop.fill"
        case "mexican":
            return "flame.fill"
        case "indian":
            return "star.fill"
        case "french":
            return "heart.fill"
        case "american":
            return "flag.fill"
        case "chinese":
            return "circle.fill"
        default:
            return "fork.knife"
        }
    }
    
    static func restaurantGradientColors(for restaurant: Restaurant) -> [Color] {
        let baseColors = gradientColors(for: restaurant.cuisine)
        
        // Adjust intensity based on rating
        if restaurant.rating >= 4.5 {
            return baseColors // High rating - vibrant colors
        } else if restaurant.rating >= 4.0 {
            return baseColors.map { $0.opacity(0.8) } // Good rating - slightly muted
        } else {
            return baseColors.map { $0.opacity(0.6) } // Lower rating - more muted
        }
    }
}
