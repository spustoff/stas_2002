//
//  RestaurantViewModel.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class RestaurantViewModel: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var favoriteRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var selectedCuisine: String = "All"
    @Published var selectedPriceRange: Restaurant.PriceRange?
    @Published var selectedFeatures: Set<Restaurant.RestaurantFeature> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var userLocation: CLLocation?
    @Published var sortBy: SortOption = .distance
    
    private let dataStore: DataStore
    private let locationManager = CLLocationManager()
    private var locationDelegate: LocationManagerDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    enum SortOption: String, CaseIterable {
        case distance = "Distance"
        case rating = "Rating"
        case name = "Name"
        case priceRange = "Price"
    }
    
    let cuisines = ["All", "Italian", "Japanese", "Mexican", "Thai", "Indian", "French", "American", "Chinese"]
    
    init(dataStore: DataStore = .shared) {
        self.dataStore = dataStore
        setupLocationManager()
        loadRestaurants()
        setupSearchAndFilters()
    }
    
    var filteredAndSortedRestaurants: [Restaurant] {
        var filtered = restaurants
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.description.localizedCaseInsensitiveContains(searchText) ||
                restaurant.cuisine.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by cuisine
        if selectedCuisine != "All" {
            filtered = filtered.filter { $0.cuisine == selectedCuisine }
        }
        
        // Filter by price range
        if let priceRange = selectedPriceRange {
            filtered = filtered.filter { $0.priceRange == priceRange }
        }
        
        // Filter by features
        if !selectedFeatures.isEmpty {
            filtered = filtered.filter { restaurant in
                selectedFeatures.allSatisfy { feature in
                    restaurant.features.contains(feature)
                }
            }
        }
        
        // Sort restaurants
        return sortRestaurants(filtered)
    }
    
    private func sortRestaurants(_ restaurants: [Restaurant]) -> [Restaurant] {
        switch sortBy {
        case .distance:
            guard let userLocation = userLocation else { return restaurants }
            return restaurants.sorted { restaurant1, restaurant2 in
                let distance1 = userLocation.distance(from: CLLocation(latitude: restaurant1.latitude, longitude: restaurant1.longitude))
                let distance2 = userLocation.distance(from: CLLocation(latitude: restaurant2.latitude, longitude: restaurant2.longitude))
                return distance1 < distance2
            }
        case .rating:
            return restaurants.sorted { $0.rating > $1.rating }
        case .name:
            return restaurants.sorted { $0.name < $1.name }
        case .priceRange:
            return restaurants.sorted { restaurant1, restaurant2 in
                let order: [Restaurant.PriceRange] = [.budget, .moderate, .expensive, .luxury]
                let index1 = order.firstIndex(of: restaurant1.priceRange) ?? 0
                let index2 = order.firstIndex(of: restaurant2.priceRange) ?? 0
                return index1 < index2
            }
        }
    }
    
    private func setupLocationManager() {
        locationDelegate = LocationManagerDelegate(viewModel: self)
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationPermission()
    }
    
    private func setupSearchAndFilters() {
        // Debounce search to avoid excessive filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { _ in
                // Trigger UI update through filteredAndSortedRestaurants computed property
            }
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied permission
            errorMessage = "Location access is required to show nearby restaurants"
        @unknown default:
            break
        }
    }
    
    func loadRestaurants() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedRestaurants = try await dataStore.loadRestaurants()
                await MainActor.run {
                    self.restaurants = loadedRestaurants
                    self.updateFavoriteRestaurants()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load restaurants: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func toggleFavorite(for restaurant: Restaurant) {
        if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
            restaurants[index] = Restaurant(
                name: restaurant.name,
                description: restaurant.description,
                cuisine: restaurant.cuisine,
                address: restaurant.address,
                phoneNumber: restaurant.phoneNumber,
                website: restaurant.website,
                rating: restaurant.rating,
                priceRange: restaurant.priceRange,
                imageURL: restaurant.imageURL,
                latitude: restaurant.latitude,
                longitude: restaurant.longitude,
                openingHours: restaurant.openingHours,
                features: restaurant.features,
                isFavorite: !restaurant.isFavorite
            )
            
            // Update user profile
            if restaurant.isFavorite {
                dataStore.removeFavoriteRestaurant(restaurant.id)
            } else {
                dataStore.addFavoriteRestaurant(restaurant.id)
            }
            
            updateFavoriteRestaurants()
        }
    }
    
    private func updateFavoriteRestaurants() {
        favoriteRestaurants = restaurants.filter { $0.isFavorite }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCuisine = "All"
        selectedPriceRange = nil
        selectedFeatures.removeAll()
        sortBy = .distance
    }
    
    func getRestaurantById(_ id: UUID) -> Restaurant? {
        return restaurants.first { $0.id == id }
    }
    
    func distanceToRestaurant(_ restaurant: Restaurant) -> String? {
        guard let userLocation = userLocation else { return nil }
        let restaurantLocation = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let distance = userLocation.distance(from: restaurantLocation)
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func refreshRestaurants() {
        loadRestaurants()
    }
}

// MARK: - Location Manager Delegate
private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    weak var viewModel: RestaurantViewModel?
    
    init(viewModel: RestaurantViewModel) {
        self.viewModel = viewModel
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            viewModel?.userLocation = location
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            viewModel?.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            viewModel?.requestLocationPermission()
        }
    }
}
