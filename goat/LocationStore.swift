//
//  LocationStore.swift
//  goat
//
//  Created by Chen Wu on 12/15/18.
//  Copyright © 2018 Chen Wu. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationRequestResponse {
    case success
    case failure
}

class LocationStore: NSObject {
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    @objc dynamic var location: CLLocation?
    
    func requestUserPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
             fallthrough
        case .authorizedWhenInUse:
            self.locationManager.requestLocation()
        case .restricted, .denied:
            break
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationStore: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            assertionFailure()
            return
        }
        self.location = location
    }
}
