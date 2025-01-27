//
//  ShadowWisperJournalsApp.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import Firebase
import SwiftUI

/**
 `ShadowWisperJournalsApp` ist der Startpunkt der gesamten App in SwiftUI.
 
 **Aufgaben**:
 - Initialisiert Firebase über `FirebaseApp.configure()` (z. B. für Datenbank, Authentifizierung etc.).
 - Bindet einen `AppDelegate` über `@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate` ein,
 falls systemweite Funktionen (z. B. Google Maps API-Key-Setzung) benötigt werden.
 - Stellt ein zentrales `WindowGroup` bereit, in dem `RootView` gerendert wird.
 - Setzt einen globalen Font (`SmoochSans-Regular`) über die Umgebungseinstellung
 (environment(\.font, ...)).
 
 **Verwendung**:
 Wenn die App gestartet wird, ist `ShadowWisperJournalsApp` die Entry-Point-Klasse (durch `@main`).
 Hier wird der `userViewModel` erzeugt und als `EnvironmentObject` in den View-Hierarchie-Kontext
 übergeben, damit andere Views (z. B. `RootView`) darauf zugreifen können.
 */
@main
struct ShadowWisperJournalsApp: App {
    
    /// Bindet den AppDelegate für plattform-/frameworkspezifische Einstellungen (z. B. Google Maps).
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// Ein zentrales ViewModel für den Nutzerzustand (Anmeldung, Registrierung, etc.).
    @StateObject private var userViewModel = ShadowWisperUserViewModel()
    
    /**
     Initialisiert die App und konfiguriert Firebase, sodass Datenbank-
     und Auth-Funktionen bereitstehen.
     */
    init() {
        FirebaseApp.configure()
    }
    
    // MARK: - Body
    
    /**
     Definiert die Hauptszene der Anwendung.
     `RootView` wird als Start-View angezeigt und erhält `userViewModel` als EnvironmentObject.
     Zusätzlich wird ein globaler Font für die gesamte App via `.environment(\.font, ...)` gesetzt.
     */
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userViewModel)
            // Setzt die Standard-Schriftart "SmoochSans-Regular" für die gesamte App
                .environment(\.font,
                              .custom("SmoochSans-Regular", size: 16)
                )
        }
    }
}
