//
//  NotesSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `NotesSection` ist eine View-Komponente, die es dem Benutzer ermöglicht,
/// persönliche Notizen zu schreiben, zu bearbeiten und zu kopieren.
///
/// Hauptfunktionen:
/// - Textbearbeitung mit einem `TextEditor`.
/// - Möglichkeit, die Notizen in die Zwischenablage zu kopieren.
/// - Temporäre Toast-Benachrichtigung, um den Benutzer über das Kopieren zu informieren.
struct NotesSection: View {
    
    /// Binding-Variable, die den Inhalt der persönlichen Notizen speichert.
    @Binding var personalNotes: String
    
    /// Zustand, der steuert, ob der Toast für die Kopierbestätigung angezeigt wird.
    @State private var showToast: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Überschrift
            /// Titel der Sektion "Meine Notizen".
            Text("Meine Notizen")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Farbe für den Titel
            
            // MARK: - TextEditor
            /// Textbearbeitungsfeld für die persönlichen Notizen.
            TextEditor(text: $personalNotes)
                .font(.custom("SmoochSans-Regular", size: 20)) // Benutzerdefinierte Schriftart
                .padding() // Innenabstand
                .background(Color.white.opacity(0.1)) // Hintergrundfarbe mit Transparenz
                .cornerRadius(8) // Abgerundete Ecken
                .foregroundColor(.white) // Textfarbe
                .frame(minHeight: 100) // Mindesthöhe des Editors
            
            // MARK: - Kopieren-Button
            /// Button, um die Notizen in die Zwischenablage zu kopieren.
            Button(action: {
                UIPasteboard.general.string = personalNotes // Notizen kopieren
                showToast = true // Toast anzeigen
                // Toast nach 2 Sekunden ausblenden
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showToast = false
                    }
                }
            }) {
                Text("Notizen kopieren") // Beschriftung des Buttons
                    .font(.custom("SmoochSans-Regular", size: 18)) // Benutzerdefinierte Schriftart
                    .foregroundColor(AppColors.signalColor2) // Button-Farbe
            }
            .buttonStyle(PlainButtonStyle()) // Entfernt Standard-Button-Stile
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
        
        // MARK: - Toast-Benachrichtigung
        .overlay(
            VStack {
                if showToast {
                    Spacer()
                    HStack {
                        Spacer()
                        // Toast-Inhalt
                        Text("Notizen kopiert!")
                            .font(.custom("SmoochSans-Regular", size: 16)) // Benutzerdefinierte Schriftart
                            .foregroundColor(.white) // Textfarbe
                            .padding() // Innenabstand
                            .background(Color.black.opacity(0.7)) // Hintergrundfarbe
                            .cornerRadius(8) // Abgerundete Ecken für den Toast
                        Spacer()
                    }
                    .padding(.bottom, 20) // Abstand nach unten
                    .transition(.move(edge: .bottom).combined(with: .opacity)) // Übergangseffekt
                    .animation(.easeInOut, value: showToast) // Animation für den Toast
                }
            }
        )
    }
}
