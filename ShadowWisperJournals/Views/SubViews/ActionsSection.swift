//
//  ActionsSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `ActionsSection` ist eine wiederverwendbare View-Komponente, die zwei Aktionen bereitstellt:
/// - **Speichern:** Eine Aktion, die vom Benutzer definiert wird.
/// - **Löschen:** Eine Aktion, die ebenfalls benutzerdefiniert ist.
///
/// Diese Komponente bietet ansprechende Schaltflächen mit einer benutzerdefinierten Gestaltung,
/// die zu den App-Farben passt.
struct ActionsSection: View {
    
    /// Die Aktion, die beim Drücken der "Speichern"-Schaltfläche ausgeführt wird.
    var saveAction: () -> Void
    
    /// Die Aktion, die beim Drücken der "Löschen"-Schaltfläche ausgeführt wird.
    var deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            
            // MARK: - Speichern-Schaltfläche
            Button(action: saveAction) {
                Text("Speichern")
                    .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                    .foregroundColor(.black) // Textfarbe
                    .padding()
                    .frame(maxWidth: .infinity) // Breite füllt den verfügbaren Platz
                    .background(
                        // Farbverlauf für die Schaltfläche
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.signalColor1, // Erste Farbe des Gradienten
                                AppColors.signalColor5  // Zweite Farbe des Gradienten
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8) // Abgerundete Ecken
                    .shadow(
                        color: AppColors.signalColor1.opacity(0.8), // Schattenfarbe mit Transparenz
                        radius: 10, // Schattenradius
                        x: 0,
                        y: 5 // Vertikale Schattenverschiebung
                    )
            }
            
            // MARK: - Löschen-Schaltfläche
            Button(action: deleteAction) {
                Text("Löschen")
                    .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                    .foregroundColor(.white) // Textfarbe
                    .padding()
                    .frame(maxWidth: .infinity) // Breite füllt den verfügbaren Platz
                    .background(
                        // Farbverlauf für die Schaltfläche
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.signalColor3, // Erste Farbe des Gradienten
                                AppColors.signalColor4  // Zweite Farbe des Gradienten
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8) // Abgerundete Ecken
                    .shadow(
                        color: AppColors.signalColor3.opacity(0.8), // Schattenfarbe mit Transparenz
                        radius: 10, // Schattenradius
                        x: 0,
                        y: 5 // Vertikale Schattenverschiebung
                    )
            }
            .buttonStyle(PlainButtonStyle()) // Entfernt Standard-Button-Stile
        }
        .padding() // Gesamte View mit Innenabstand
    }
}
