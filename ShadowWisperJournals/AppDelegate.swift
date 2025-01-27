//
//  AppDelegate.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 12.01.25.
//

import UIKit
import GoogleMaps
import Firebase

/**
 `AppDelegate` ist der Einstiegspunkt für die App auf iOS-Ebene.
 
 **Funktionen**:
 - Setzt den Google Maps API-Key (`GMSServices.provideAPIKey(...)`)
 - Initialisiert Firebase (optional, sobald entsprechende Aufrufe hinzukommen)
 - Reagiert auf Anwendungslaufzeitereignisse wie Start, Beenden und verschiedene System-Events
 
 **Hinweis**:
 Um Firebase zu verwenden, füge ggf. `FirebaseApp.configure()` hinzu,
 falls es nicht bereits an anderer Stelle geschieht.
 */
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /**
     Wird aufgerufen, sobald die App fertig gestartet ist.
     
     - Parameter application: Die `UIApplication`-Instanz.
     - Parameter launchOptions: Ein Dictionary mit Informationen zum Startvorgang (z. B. URLs,
     Benachrichtigungen etc.), kann `nil` sein.
     
     - Returns: Ein Bool-Wert, der angibt, ob das Starten erfolgreich war (`true`).
     */
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        // Setze den Google Maps API-Key, sodass Karten und Geocoding genutzt werden können
        GMSServices.provideAPIKey("AIzaSyC5hx7FGU09gxrRW5pnU8ldI-PPK7dl76c")
        
        // Optionale Firebase-Konfiguration, falls benötigt:
        // FirebaseApp.configure()
        
        return true
    }
}
