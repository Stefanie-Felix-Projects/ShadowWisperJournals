//
//  LocationSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `LocationSection` ist eine View-Komponente, die es dem Benutzer ermöglicht, einen Standort als Text einzugeben
/// und diesen Standort auf einer Karte darzustellen.
///
/// Hauptfunktionen:
/// - Eingabefeld für eine Standortadresse.
/// - Dynamische Kartenansicht basierend auf der eingegebenen Adresse.
/// - Integration mit `GoogleMapView` für die Darstellung der Karte.
struct LocationSection: View {
    
    /// Binding-Variable, die die vom Benutzer eingegebene Standortadresse verwaltet.
    @Binding var localLocationString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Überschrift
            /// Text "Standort / Karte" als Überschrift für die Sektion.
            Text("Standort / Karte")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Titel-Farbe
            
            // MARK: - Eingabefeld für die Adresse
            /// Textfeld für die Eingabe der Standortadresse.
            TextField("Standort-Adresse", text: $localLocationString)
                .font(.custom("SmoochSans-Regular", size: 20)) // Benutzerdefinierte Schriftart
                .padding() // Innenabstand im Eingabefeld
                .background(Color.white.opacity(0.1)) // Halbtransparenter Hintergrund
                .cornerRadius(8) // Abgerundete Ecken für das Textfeld
                .foregroundColor(.white) // Textfarbe
                .textInputAutocapitalization(.never) // Verhindert automatische Großschreibung
            
            // MARK: - Kartenansicht
            /// Darstellung der Karte basierend auf der eingegebenen Adresse.
            GoogleMapView(locationString: localLocationString)
                .frame(height: 200) // Festgelegte Höhe der Kartenansicht
                .cornerRadius(12) // Abgerundete Ecken für die Karte
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
