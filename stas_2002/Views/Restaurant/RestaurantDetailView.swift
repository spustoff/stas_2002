//
//  RestaurantDetailView.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var isFavorite: Bool
    
    init(restaurant: Restaurant, isFavorite: Bool = false) {
        self.restaurant = restaurant
        self._isFavorite = State(initialValue: isFavorite)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image with gradient
                ZStack {
                    LinearGradient(
                        colors: ImageHelpers.restaurantGradientColors(for: restaurant),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 250)
                    
                    // Decorative restaurant pattern
                    VStack {
                        HStack {
                            Image(systemName: ImageHelpers.cuisineIcon(for: restaurant.cuisine))
                                .font(.system(size: 45, weight: .light))
                                .foregroundColor(.white.opacity(0.4))
                            Spacer()
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 35, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        Spacer()
                        HStack {
                            ForEach(0..<Int(restaurant.rating), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 40, weight: .ultraLight))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(25)
                    
                    // Overlay with restaurant info
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(restaurant.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                
                                HStack {
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color("GoldenYellow"))
                                        Text(restaurant.formattedRating)
                                            .fontWeight(.medium)
                                    }
                                    
                                    Text("•")
                                    
                                    Text(restaurant.priceRange.rawValue)
                                    
                                    Text("•")
                                    
                                    Text(restaurant.cuisine)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isFavorite.toggle()
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(isFavorite ? Color("AccentRed") : .white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 44, height: 44)
                                    )
                            }
                        }
                        .padding(20)
                    }
                }
                
                // Quick actions
                HStack(spacing: 16) {
                    if let phone = restaurant.phoneNumber {
                        QuickActionButton(icon: "phone.fill", title: "Call", color: Color("VibrantGreen")) {
                            if let url = URL(string: "tel:\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    QuickActionButton(icon: "location.fill", title: "Directions", color: Color("PrimaryRed")) {
                        openInMaps()
                    }
                    
                    if let website = restaurant.website {
                        QuickActionButton(icon: "safari.fill", title: "Website", color: Color("GoldenYellow")) {
                            if let url = URL(string: website) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    QuickActionButton(icon: "square.and.arrow.up", title: "Share", color: Color("AccentRed")) {
                        shareRestaurant()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Description
                if !restaurant.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(restaurant.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                // Address and distance
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(Color("VibrantGreen"))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(restaurant.address)
                                .font(.body)
                            
                            Text("Restaurant location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Mini map
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: restaurant.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )), annotationItems: [restaurant]) { restaurant in
                        MapPin(coordinate: restaurant.coordinate, tint: Color("AccentRed"))
                    }
                    .frame(height: 150)
                    .cornerRadius(12)
                    .allowsHitTesting(false)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Opening hours
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hours")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ForEach(restaurant.openingHours, id: \.day) { schedule in
                            HStack {
                                Text(schedule.day.rawValue)
                                    .font(.body)
                                    .frame(width: 80, alignment: .leading)
                                
                                Spacer()
                                
                                Text(schedule.displayText)
                                    .font(.body)
                                    .foregroundColor(schedule.isClosed ? .secondary : .primary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Features
                if !restaurant.features.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(restaurant.features, id: \.self) { feature in
                                Text(feature.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("VibrantGreen").opacity(0.1))
                                    .foregroundColor(Color("VibrantGreen"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: restaurant.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func shareRestaurant() {
        let text = "Check out \(restaurant.name) - \(restaurant.description)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    NavigationView {
        RestaurantDetailView(restaurant: Restaurant.sampleRestaurants[0], isFavorite: false)
    }
}
