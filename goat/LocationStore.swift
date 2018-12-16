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

    var callBack: LocationRequestResponseCallback?
    
    typealias LocationRequestResponseCallback = (LocationRequestResponse) -> Void
    func requestUserPermission(completionHandler: @escaping LocationRequestResponseCallback) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
             fallthrough
        case .authorizedWhenInUse:
            self.locationManager.requestLocation()
            completionHandler(.success)
        case .restricted, .denied:
            completionHandler(.failure)
        case .notDetermined:
            self.callBack = completionHandler
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension LocationStore: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.callBack?(.success)
        default:
            self.callBack?(.failure)
        }
        self.callBack = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            assertionFailure()
            return
        }
        self.location = location
    }
}
