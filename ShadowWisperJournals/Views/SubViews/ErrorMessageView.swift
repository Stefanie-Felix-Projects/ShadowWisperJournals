//
//  ErrorMessageView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `ErrorMessageView` ist eine View-Komponente, die eine Fehlermeldung anzeigt.
///
/// Hauptfunktionen:
/// - Zeigt eine Fehlermeldung in roter Farbe an.
/// - Verwendet eine benutzerdefinierte Schriftart, um die Lesbarkeit zu verbessern.
/// - Fokussiert sich auf minimalistische Darstellung.
struct ErrorMessageView: View {
    
    /// Die Fehlermeldung, die angezeigt werden soll.
    var errorMessage: String
    
    var body: some View {
        Text(errorMessage) // Text für die Fehlermeldung
            .foregroundColor(.red) // Textfarbe: Rot für Fehler
            .font(.custom("SmoochSans-Bold", size: 16)) // Benutzerdefinierte Schriftart
            .padding() // Abstand um den Text
    }
}
