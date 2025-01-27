//
//  SelectableCharacterRow.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI

/// `SelectableCharacterRow` ist eine View-Komponente, die eine Charakterzeile anzeigt.
/// Diese Zeile bietet dem Benutzer die Möglichkeit, den Charakter auszuwählen oder die Auswahl aufzuheben.
///
/// Hauptfunktionen:
/// - Darstellung eines Charakters mit Profilbild, Namen und optionaler Spezialisierung.
/// - Möglichkeit, den Charakter durch einen Button auszuwählen oder die Auswahl aufzuheben.
struct SelectableCharacterRow: View {
    
    /// Der Charakter, der in der Zeile dargestellt wird.
    let character: Character
    
    /// Gibt an, ob der Charakter aktuell ausgewählt ist.
    let isSelected: Bool
    
    /// Aktion, die ausgeführt wird, wenn der Benutzer den Auswahlstatus ändert.
    let toggleSelection: () -> Void
    
    var body: some View {
        HStack {
            
            // MARK: - Profilbild
            if let profileImageURL = character.profileImageURL, let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Ladeanzeige, wenn das Bild noch geladen wird.
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        // Erfolgreich geladenes Bild.
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle()) // Runde Form
                    case .failure:
                        // Platzhalterbild, wenn das Laden fehlschlägt.
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
                // Platzhalterbild, wenn kein Profilbild vorhanden ist.
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Charakterinformationen
            VStack(alignment: .leading) {
                // Name des Charakters
                Text(character.name)
                    .font(.headline) // Hauptschriftart für den Namen
                
                // Optional: Spezialisierung des Charakters
                if let metaType = character.specialization {
                    Text(metaType)
                        .font(.subheadline) // Untergeordnete Schriftart
                        .foregroundColor(.gray) // Graue Farbe
                }
            }
            
            Spacer() // Platz zwischen den Informationen und dem Button
            
            // MARK: - Auswahl-Button
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle") // Symbol basierend auf dem Auswahlstatus
                    .resizable()
                    .frame(width: 24, height: 24) // Größe des Symbols
                    .foregroundColor(isSelected ? .blue : .gray) // Farbe basierend auf dem Status
            }
        }
        .padding(.vertical, 4) // Abstand zwischen den Zeilen
    }
}
