//
//  GoogleMapView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 12.01.25.
//

import SwiftUI
import GoogleMaps
import CoreLocation

struct GoogleMapView: UIViewRepresentable {
    var locationString: String?
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 51.0, longitude: 10.0, zoom: 5.0)
        
        let mapView = GMSMapView()
        mapView.camera = camera
        
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        guard let locationString = locationString, !locationString.isEmpty else {
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { placemarks, error in
            if let error = error {
                print("Geocode error: \(error.localizedDescription)")
                return
            }
            guard let placemark = placemarks?.first,
                  let coordinate = placemark.location?.coordinate else {
                print("Keine Geocode-Ergebnisse für \(locationString).")
                return
            }
            
            let camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: 14
            )
            uiView.animate(to: camera)
            
            let marker = GMSMarker(position: coordinate)
            marker.title = locationString
            marker.map = uiView
        }
    }
}
