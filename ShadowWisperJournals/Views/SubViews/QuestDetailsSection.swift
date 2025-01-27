//
//  QuestDetailsSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `QuestDetailsSection` ist eine View-Komponente, die Eingabefelder und Auswahlmöglichkeiten
/// für die Details einer Quest bereitstellt.
///
/// Hauptfunktionen:
/// - Eingabefelder für Titel, Beschreibung und Belohnung.
/// - Auswahl des Status über einen `Picker`.
/// - Benutzerfreundliche und ansprechende Gestaltung.
struct QuestDetailsSection: View {
    
    /// Binding-Variable für den Titel der Quest.
    @Binding var title: String
    
    /// Binding-Variable für die Beschreibung der Quest.
    @Binding var description: String
    
    /// Binding-Variable für den Status der Quest (z. B. "aktiv" oder "abgeschlossen").
    @Binding var status: String
    
    /// Binding-Variable für die Belohnung der Quest.
    @Binding var reward: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Überschrift
            /// Titel der Sektion "Quest-Details".
            Text("Quest-Details")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Titel-Farbe
            
            // MARK: - Eingabefeld: Titel
            /// Textfeld für den Titel der Quest.
            TextField("Titel", text: $title)
                .font(.custom("SmoochSans-Bold", size: 20)) // Benutzerdefinierte Schriftart
                .padding() // Innenabstand
                .background(Color.white.opacity(0.1)) // Halbtransparenter Hintergrund
                .cornerRadius(8) // Abgerundete Ecken
                .foregroundColor(.white) // Textfarbe
            
            // MARK: - Eingabefeld: Beschreibung
            /// Textfeld für die Beschreibung der Quest.
            TextField("Beschreibung", text: $description)
                .font(.custom("SmoochSans-Regular", size: 20)) // Benutzerdefinierte Schriftart
                .padding() // Innenabstand
                .background(Color.white.opacity(0.1)) // Halbtransparenter Hintergrund
                .cornerRadius(8) // Abgerundete Ecken
                .foregroundColor(.white) // Textfarbe
            
            // MARK: - Picker: Status
            /// Segmentierter Picker für den Status der Quest.
            Picker("Status", selection: $status) {
                Text("Aktiv").tag("aktiv") // Tag für den aktiven Status
                    .font(.custom("SmoochSans-Bold", size: 18))
                Text("Abgeschlossen").tag("abgeschlossen") // Tag für den abgeschlossenen Status
                    .font(.custom("SmoochSans-Bold", size: 18))
            }
            .pickerStyle(.segmented) // Segementierter Stil für den Picker
            .padding(.vertical, 8) // Vertikaler Abstand
            
            // MARK: - Eingabefeld: Belohnung
            /// Textfeld für die Belohnung der Quest.
            TextField("Belohnung", text: $reward)
                .font(.custom("SmoochSans-Bold", size: 20)) // Benutzerdefinierte Schriftart
                .padding() // Innenabstand
                .background(Color.white.opacity(0.1)) // Halbtransparenter Hintergrund
                .cornerRadius(8) // Abgerundete Ecken
                .foregroundColor(.white) // Textfarbe
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
