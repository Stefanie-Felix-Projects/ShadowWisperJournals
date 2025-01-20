//
//  AssignCharactersView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 07.01.25.
//

import SwiftUI

struct AssignCharactersView: View {
    @Environment(\.dismiss) var dismiss
    
    let quest: Quest
    
    @EnvironmentObject var questLogVM: QuestLogViewModel
    
    @StateObject private var characterVM = CharacterViewModel()
    @State private var selectedCharacterIds: [String] = []
    
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Alle verfügbaren Charaktere") {
                    let allCharacters = characterVM.characters
                    
                    if allCharacters.isEmpty {
                        Text("Keine Charaktere vorhanden.")
                            .foregroundColor(.gray)
                    } else {
                        List(allCharacters, id: \ .id) { character in
                            let cId = character.id ?? ""
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
                
                Section {
                    Button("Zuweisen") {
                        questLogVM.assignCharactersToQuest(
                            quest: quest,
                            characterIds: selectedCharacterIds
                        )
                        dismiss()
                    }
                    .disabled(selectedCharacterIds.isEmpty)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Charaktere zuweisen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                characterVM.fetchAllCharacters()
            }
        }
        .background(Color.clear)
    }
}
