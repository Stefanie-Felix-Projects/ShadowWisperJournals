//
//  AssignCharactersView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 07.01.25.
// Test

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
                Section("Verfügbare Charaktere anderer Nutzer") {
                    let otherUsersCharacters = characterVM.characters.filter {
                        $0.userId != userViewModel.userId
                    }

                    if otherUsersCharacters.isEmpty {
                        Text("Keine Charaktere anderer Nutzer vorhanden.")
                            .foregroundColor(.gray)
                    } else {
                        List(otherUsersCharacters, id: \.id) { character in
                            MultipleSelectionRow(
                                title: character.name,
                                isSelected: selectedCharacterIds.contains(
                                    character.id ?? "")
                            ) {
                                toggleSelection(for: character.id ?? "")
                            }
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
    }

    private func toggleSelection(for characterId: String) {
        if selectedCharacterIds.contains(characterId) {
            selectedCharacterIds.removeAll { $0 == characterId }
        } else {
            selectedCharacterIds.append(characterId)
        }
    }
}
