//
//  AddQuestView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    @EnvironmentObject var characterVM: CharacterViewModel

    @ObservedObject var questLogVM: QuestLogViewModel
    let userId: String
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: String = "aktiv"
    @State private var reward: String = ""
    
    // Mehrfachauswahl
    @State private var selectedCharacterIds: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quest-Daten") {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                    TextField("Belohnung (optional)", text: $reward)
                    
                    Picker("Status", selection: $status) {
                        Text("Aktiv").tag("aktiv")
                        Text("Abgeschlossen").tag("abgeschlossen")
                    }
                    .pickerStyle(.segmented)
                }
                
                // Charaktere zuweisen (Liste aller Characters)
                Section("Charaktere zuweisen") {
                    let availableCharacters = characterVM.characters
                    
                    if availableCharacters.isEmpty {
                        Text("Keine Charaktere verfügbar.")
                            .foregroundColor(.gray)
                    } else {
                        List(availableCharacters, id: \.id) { character in
                            let cId = character.id ?? ""
                            
                            MultipleSelectionRow(
                                title: character.name,
                                isSelected: selectedCharacterIds.contains(cId)
                            ) {
                                if selectedCharacterIds.contains(cId) {
                                    selectedCharacterIds.removeAll { $0 == cId }
                                } else {
                                    selectedCharacterIds.append(cId)
                                }
                            }
                        }
                        .frame(minHeight: 200)
                    }
                }
                
                Button("Quest hinzufügen") {
                    guard !title.isEmpty, !description.isEmpty else { return }
                    
                    questLogVM.addQuest(
                        title: title,
                        description: description,
                        status: status,
                        reward: reward.isEmpty ? nil : reward,
                        userId: userId,
                        creatorDisplayName: userViewModel.user?.displayName,
                        assignedCharacterIds: selectedCharacterIds.isEmpty ? nil : selectedCharacterIds
                    )
                    
                    dismiss()
                }
            }
            .navigationTitle("Neue Quest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}
