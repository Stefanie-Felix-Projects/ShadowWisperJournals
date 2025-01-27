//
//  CreatedBySection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `CreatedBySection` ist eine View-Komponente, die den Ersteller eines Objekts (z. B. einer Quest)
/// anzeigt. Sie bietet eine klare und ästhetische Darstellung der Informationen.
///
/// Hauptfunktionen:
/// - Zeigt den Titel "Erstellt von".
/// - Zeigt den Namen des Erstellers mit ansprechendem Stil an.
struct CreatedBySection: View {
    
    /// Der Name des Erstellers, der angezeigt werden soll.
    var creatorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Titel
            /// Text "Erstellt von" als Überschrift.
            Text("Erstellt von")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Farbe für die Überschrift
            
            // MARK: - Erstellername
            /// Text mit dem Namen des Erstellers.
            Text(creatorName)
                .font(.custom("SmoochSans-Regular", size: 20)) // Benutzerdefinierte Schriftart
                .foregroundColor(.white) // Farbe für den Namen
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
