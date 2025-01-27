//
//  AssignedCharactersSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `AssignedCharactersSection` ist eine View-Komponente, die eine Liste der zu einer Quest
/// zugewiesenen Charaktere anzeigt und es ermöglicht, weitere Charaktere hinzuzufügen.
///
/// Hauptfunktionen:
/// - Anzeige der zu einer Quest zugewiesenen Charaktere.
/// - Möglichkeit, weitere Charaktere zuzuweisen.
/// - Integration mit dem `CharacterViewModel`, um Charakterdaten abzurufen.
struct AssignedCharactersSection: View {
    
    /// Binding-Variable, um das Anzeigen des `AssignCharactersSheet` zu steuern.
    @Binding var showAssignCharactersSheet: Bool
    
    /// Die Quest, zu der Charaktere zugewiesen sind.
    var quest: Quest
    
    /// ViewModel, das die Liste aller Charaktere verwaltet.
    @EnvironmentObject var characterVM: CharacterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Überschrift und Button
            HStack {
                Text("Zugewiesene Charaktere")
                    .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                    .foregroundColor(AppColors.signalColor4) // Titel-Farbe
                Spacer()
                Button(action: {
                    showAssignCharactersSheet = true
                }) {
                    Image(systemName: "person.badge.plus") // Symbol für Hinzufügen
                        .foregroundColor(AppColors.signalColor2) // Button-Farbe
                }
                .buttonStyle(PlainButtonStyle()) // Entfernt den Standard-Button-Stil
            }
            
            // MARK: - Liste der zugewiesenen Charaktere
            if let assignedCharacterIds = quest.assignedCharacterIds, !assignedCharacterIds.isEmpty {
                ForEach(assignedCharacterIds, id: \.self) { charId in
                    if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                        
                        // Einzelner Charakter-Eintrag
                        HStack {
                            // Profilbild oder Platzhalter
                            if let profileImageURL = foundChar.profileImageURL,
                               let url = URL(string: profileImageURL) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Ladeanzeige
                                            .frame(width: 40, height: 40)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle()) // Kreisform
                                    case .failure:
                                        Image(systemName: "person.crop.circle.fill") // Platzhalter
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill") // Platzhalter
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            // Charakter-Details
                            VStack(alignment: .leading) {
                                Text(foundChar.name) // Charaktername
                                    .font(.custom("SmoochSans-Bold", size: 20))
                                    .foregroundColor(.white)
                                if let metaType = foundChar.metaType {
                                    Text(metaType) // Charaktertyp (z. B. "Elf", "Mensch")
                                        .font(.custom("SmoochSans-Regular", size: 18))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 4) // Abstand zwischen den Einträgen
                        
                    } else {
                        // Anzeige, wenn ein Charakter nicht gefunden wird
                        Text("Unbekannter Charakter (ID: \(charId))")
                            .foregroundColor(.gray)
                            .font(.custom("SmoochSans-Regular", size: 18))
                    }
                }
            } else {
                // Anzeige, wenn keine Charaktere zugewiesen sind
                Text("Keine Charaktere zugewiesen.")
                    .foregroundColor(.gray)
                    .font(.custom("SmoochSans-Regular", size: 18))
            }
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
