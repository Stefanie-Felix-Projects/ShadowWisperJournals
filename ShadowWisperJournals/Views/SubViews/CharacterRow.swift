//
//  CharacterRow.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI

/// `CharacterRow` ist eine View-Komponente, die eine einzelne Zeile darstellt, um Informationen
/// über einen Charakter anzuzeigen. Sie enthält ein Profilbild, den Namen, eine Spezialisierung
/// und eine Auswahl-Option.
///
/// Hauptfunktionen:
/// - Anzeige eines Charakterprofils (inkl. Bild, Name und Spezialisierung).
/// - Möglichkeit, den Charakter auszuwählen oder die Auswahl aufzuheben.
///
/// Diese View wird typischerweise in einer Liste von Charakteren verwendet.
struct CharacterRow: View {
    
    /// Der Charakter, dessen Informationen angezeigt werden sollen.
    let character: Character
    
    /// Gibt an, ob der Charakter aktuell ausgewählt ist.
    let isSelected: Bool
    
    /// Eine Aktion, die ausgelöst wird, wenn die Auswahl geändert wird.
    let toggleSelection: () -> Void
    
    var body: some View {
        HStack {
            
            // MARK: - Profilbild
            if let profileImageURL = character.profileImageURL, let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Ladeanzeige, wenn das Bild geladen wird.
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        // Erfolgreich geladenes Bild.
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle()) // Rundes Profilbild
                    case .failure:
                        // Platzhalter, wenn das Laden fehlschlägt.
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Platzhalter, wenn kein Profilbild vorhanden ist.
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Charakterinformationen
            VStack(alignment: .leading) {
                // Charaktername
                Text(character.name)
                    .font(.custom("SmoochSans-Bold", size: 20)) // Benutzerdefinierte Schriftart
                    .foregroundColor(.white)
                
                // Spezialisierung (falls vorhanden)
                if let metaType = character.specialization {
                    Text(metaType)
                        .font(.custom("SmoochSans-Regular", size: 18)) // Benutzerdefinierte Schriftart
                        .foregroundColor(.gray)
                }
            }
            
            Spacer() // Platz zwischen Charakterinfo und Button
            
            // MARK: - Auswahl-Button
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle") // Symbol basierend auf Auswahlstatus
                    .resizable()
                    .frame(width: 24, height: 24) // Größe des Symbols
                    .foregroundColor(isSelected ? .blue : .gray) // Farbe basierend auf Auswahlstatus
            }
        }
        .padding(.vertical, 4) // Abstand zwischen den Zeilen
    }
}
