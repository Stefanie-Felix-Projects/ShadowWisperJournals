//
//  MultipleSelectionRow.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 07.01.25.
//

import SwiftUI

/**
 `MultipleSelectionRow` dient als einzelne auswählbare Zeile innerhalb einer Liste.
 
 - Zeigt einen Titel und optional ein Häkchen an, wenn der Eintrag ausgewählt ist.
 - Durch Antippen (`Button`) wird eine Aktion ausgelöst (z. B. Umschalten des Auswahlzustands).
 */
struct MultipleSelectionRow: View {
    
    /// Der anzuzeigende Text in der Zeile.
    let title: String
    
    /// Zeigt an, ob der Eintrag derzeit ausgewählt ist (`true`) oder nicht (`false`).
    let isSelected: Bool
    
    /// Wird aufgerufen, wenn die Zeile angetippt wird.
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button {
            // Führt die Aktion aus (z. B. Auswahl toggeln).
            action()
        } label: {
            HStack {
                // Titel der Zeile
                Text(title)
                
                // Dehnt den Inhalt nach rechts, damit das Checkmark am Ende steht
                Spacer()
                
                // Zeigt ein Häkchen, falls `isSelected == true`
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
