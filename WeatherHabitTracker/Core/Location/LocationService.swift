// LocationService.swift
// WeatherHabitTracker

import Foundation
import CoreLocation

@Observable
final class LocationService: NSObject, @unchecked Sendable {
    
    // MARK: - State
    
    var currentLocation: CLLocation?
    var authorizationStatus: CLAuthorizationStatus
    var errorMessage: String?
    var isLoading: Bool = false
    var locationName: String?
    
    // MARK: - Private Properties
    
    private let locationManager: CLLocationManager
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    
    // MARK: - Computed Properties
    
    var isAuthorized: Bool {
        #if os(iOS)
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
        #else
        return authorizationStatus == .authorizedAlways
        #endif
    }
    
    // MARK: - Initialization
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000
    }
    
    // MARK: - Public Methods
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() async throws -> CLLocation {
        // Return cached location if recent (5 min)
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < 300 {
            return location
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            throw LocationError.servicesDisabled
        }
        
        switch authorizationStatus {
        case .notDetermined:
            requestAuthorization()
            try await Task.sleep(for: .seconds(1))
            return try await requestLocation()
        case .restricted, .denied:
            throw LocationError.permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            break
        @unknown default:
            throw LocationError.unknown
        }
        
        isLoading = true
        errorMessage = nil
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func getPlaceName(for location: CLLocation) async -> String {
        let geocoder = CLGeocoder()
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                
                if !city.isEmpty && !state.isEmpty {
                    return "\(city), \(state)"
                } else if !city.isEmpty {
                    return "\(city), \(country)"
                } else if !state.isEmpty {
                    return "\(state), \(country)"
                } else {
                    return country
                }
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }
        
        return "Unknown Location"
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isAuthorized { errorMessage = nil }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        guard let location = locations.last else { return }
        
        currentLocation = location
        errorMessage = nil
        
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(returning: location)
        }
        
        Task { locationName = await getPlaceName(for: location) }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        let nsError = error as NSError
        
        switch nsError.code {
        case CLError.denied.rawValue:
            errorMessage = "Location access denied."
        case CLError.locationUnknown.rawValue:
            errorMessage = "Unable to determine location."
        case CLError.network.rawValue:
            errorMessage = "Network error."
        default:
            errorMessage = "Location error: \(error.localizedDescription)"
        }
        
        if let continuation = locationContinuation {
            self.locationContinuation = nil
            continuation.resume(throwing: LocationError.locationUnavailable(error.localizedDescription))
        }
    }
}

// MARK: - LocationError

enum LocationError: LocalizedError {
    case servicesDisabled
    case permissionDenied
    case locationUnavailable(String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .servicesDisabled: return "Location services disabled."
        case .permissionDenied: return "Location permission denied."
        case .locationUnavailable(let message): return "Location unavailable: \(message)"
        case .unknown: return "Unknown location error."
        }
    }
}
