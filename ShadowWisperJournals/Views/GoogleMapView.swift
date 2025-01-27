//
//  GoogleMapView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 12.01.25.
//

import SwiftUI
import GoogleMaps
import CoreLocation

/**
 `GoogleMapView` ist ein SwiftUI-Wrapper um `GMSMapView` aus dem Google Maps SDK.
 
 Diese View zeigt eine Google-Karte mit einer Startposition (z.B. Deutschland in diesem Beispiel)
 und bietet die Möglichkeit, über eine eingegebene Adresse (`locationString`) die Karte
 auf das Geocode-Ergebnis zu zoomen und einen Marker zu setzen.
 
 **Voraussetzungen**:
 - Du musst das Google Maps SDK korrekt in deinem Projekt eingebunden haben.
 - Ein valider API-Key für die Nutzung der Google Maps Services ist nötig (z. B. in `AppDelegate` oder `SceneDelegate` hinterlegt).
 - Für die Geocoding-Funktion werden Internetzugriff und gegebenenfalls Location Services benötigt.
 */
struct GoogleMapView: UIViewRepresentable {
    
    /// Die eingegebene Adresse bzw. der Ort, zu dem die Karte gezoomt werden soll.
    var locationString: String?
    
    // MARK: - makeUIView
    
    /**
     Erstellt die zugrunde liegende `GMSMapView` und konfiguriert sie.
     Wird nur einmal aufgerufen, wenn die SwiftUI-View initialisiert wird.
     
     - Parameter context: Enthält Informationen über die SwiftUI-Umgebung.
     - Returns: Eine Instanz von `GMSMapView`.
     */
    func makeUIView(context: Context) -> GMSMapView {
        // Lege eine Start-Kameraposition fest, z.B. über Deutschland (Latitude 51, Longitude 10)
        let camera = GMSCameraPosition.camera(withLatitude: 51.0, longitude: 10.0, zoom: 5.0)
        
        // Erstelle die Kartenansicht
        let mapView = GMSMapView()
        mapView.camera = camera
        
        // Aktiviert Zoom-Gesten und den MyLocation-Button
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        
        return mapView
    }
    
    // MARK: - updateUIView
    
    /**
     Aktualisiert die `GMSMapView`, wenn sich in der SwiftUI-Umgebung etwas ändert.
     In diesem Fall wird bei jeder Änderung von `locationString` versucht, die Adresse
     zu geocodieren, um die Karte darauf zu zentrieren und einen Marker zu setzen.
     
     - Parameter uiView: Die bestehende `GMSMapView`, die aktualisiert werden soll.
     - Parameter context: Enthält Informationen über die SwiftUI-Umgebung.
     */
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        guard let locationString = locationString, !locationString.isEmpty else {
            // Falls keine Adresse eingegeben ist, breche ab.
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { placemarks, error in
            if let error = error {
                print("Geocode error: \(error.localizedDescription)")
                return
            }
            
            // Nutze das erste gefundene Geocode-Ergebnis
            guard let placemark = placemarks?.first,
                  let coordinate = placemark.location?.coordinate else {
                print("Keine Geocode-Ergebnisse für \(locationString).")
                return
            }
            
            // Kamera auf die gefundene Koordinate schwenken
            let camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: 14
            )
            uiView.animate(to: camera)
            
            // Marker an der ermittelten Position setzen
            let marker = GMSMarker(position: coordinate)
            marker.title = locationString
            marker.map = uiView
        }
    }
}
