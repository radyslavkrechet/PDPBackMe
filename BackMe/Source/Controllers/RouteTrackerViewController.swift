//
//  LocationViewController.swift
//  BackMe
//
//  Created by Radislav Crechet on 6/13/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import UIKit
import MapKit

class RouteTrackerViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    private var isUpdateUserLocationOnce = false
    private var locations = [Location]()
    private var locationManager: CLLocationManager!

    private var brandColor: UIColor {
        return UIColor(red: 0.294, green: 0.663, blue: 0.929, alpha: 1.0)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Configuration
    
    private func configureLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func presentLocation(_ location: Location) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        let annotation = MKPointAnnotation()
        annotation.title = dateFormatter.string(from: location.date)
        annotation.coordinate = location.coordinate
        mapView.addAnnotation(annotation)
    }
    
    private func presentPolylineIfNeeded() {
        guard self.locations.count > 1 else {
            return
        }
        
        let locations = [self.locations[self.locations.count - 2].coordinate, self.locations.last!.coordinate]
        let polyline = MKPolyline(coordinates: locations, count: 2)
        mapView.addOverlay(polyline)
    }
    
    func trackLocation(withCoordinate coordinate: CLLocationCoordinate2D) {
        let date = Date()
        let location = Location(coordinate: coordinate, date: date)
        locations.append(location)
        presentLocation(location)
        presentPolylineIfNeeded()
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        trackLocation(withCoordinate: location.coordinate)
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !isUpdateUserLocationOnce {
            isUpdateUserLocationOnce = true
            
            let delta = 0.005
            let center = userLocation.coordinate
            let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        let size: CGFloat = 10.0
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        annotationView.layer.cornerRadius = size / 2
        annotationView.backgroundColor = brandColor
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = brandColor
        renderer.lineWidth = 2.5
        return renderer
    }
}
