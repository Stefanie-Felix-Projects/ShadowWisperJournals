//
//  AssignCharactersView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 07.01.25.
//

import SwiftUI

/**
 `AssignCharactersView` ermöglicht es, einer bestehenden Quest mehrere Charaktere zuzuweisen.
 
 Die Ansicht zeigt eine Liste aller verfügbaren Charaktere, welche durch Antippen
 ausgewählt oder abgewählt werden können. Über einen Button werden die zugewiesenen
 Charaktere in der Quest aktualisiert.
 */
struct AssignCharactersView: View {
    
    // MARK: - Environment & ObservedObject
    
    /// Ermöglicht das Dismiss (Schließen) der aktuellen View.
    @Environment(\.dismiss) var dismiss
    
    /// Die Quest, der Charaktere zugewiesen werden sollen.
    let quest: Quest
    
    /// Das ViewModel für die Verwaltung von Quests.
    /// Über `assignCharactersToQuest` werden die ausgewählten IDs hinterlegt.
    @EnvironmentObject var questLogVM: QuestLogViewModel
    
    /// Das Character-ViewModel, das alle Charakterdaten bereitstellt.
    /// Wird hier lokal instanziiert, da ggf. nur für diese Ansicht benötigt.
    @StateObject private var characterVM = CharacterViewModel()
    
    /// Speichert die aktuell ausgewählten Charakter-IDs.
    @State private var selectedCharacterIds: [String] = []
    
    /// Das User-ViewModel für Informationen zum aktuell eingeloggten Nutzer (nicht zwingend benötigt,
    /// kann aber für Rechte-Management oder Nutzer-spezifische Filter dienen).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - Body
    
    /**
     Der Aufbau erfolgt mithilfe eines `NavigationStack` und einem `Form`.
     Darin werden in einer Section alle verfügbaren Charaktere angezeigt.
     Durch eine einfache Liste können Charaktere ausgewählt werden.
     Ein weiterer Button ermöglicht das Bestätigen der Zuordnung.
     */
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Verfügbare Charaktere
                Section("Alle verfügbaren Charaktere") {
                    let allCharacters = characterVM.characters
                    
                    // Wenn keine Charaktere vorhanden sind, weise darauf hin
                    if allCharacters.isEmpty {
                        Text("Keine Charaktere vorhanden.")
                            .foregroundColor(.gray)
                    } else {
                        // Ansonsten Liste mit allen Charakteren
                        List(allCharacters, id: \.id) { character in
                            let cId = character.id ?? ""
                            // Charakter-Row mit Toggle-Logik
                            CharacterRow(
                                character: character,
                                isSelected: selectedCharacterIds.contains(cId),
                                toggleSelection: {
                                    if selectedCharacterIds.contains(cId) {
                                        selectedCharacterIds.removeAll { $0 == cId }
                                    } else {
                                        selectedCharacterIds.append(cId)
                                    }
                                }
                            )
                        }
                    }
                }
                
                // MARK: - Zuweisungs-Aktion
                Section {
                    // Schaltfläche, um die ausgewählten IDs an das QuestLogViewModel zu übergeben
                    Button("Zuweisen") {
                        questLogVM.assignCharactersToQuest(
                            quest: quest,
                            characterIds: selectedCharacterIds
                        )
                        dismiss()
                    }
                    // Deaktiviert, wenn keine Charaktere ausgewählt wurden
                    .disabled(selectedCharacterIds.isEmpty)
                }
            }
            // Hintergrund- und Layout-Anpassungen
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Charaktere zuweisen")
            .toolbar {
                // Abbrechen-Button in der NavigationBar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            // Beim Erscheinen der View werden alle Charaktere aus der Datenbank geladen
            .onAppear {
                characterVM.fetchAllCharacters()
            }
        }
        .background(Color.clear)
    }
}
