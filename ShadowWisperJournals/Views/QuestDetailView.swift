//
//  QuestDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

struct QuestDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // Das QuestViewModel
    @ObservedObject var questLogVM: QuestLogViewModel
    
    // +++ NEU: Wir binden das CharacterViewModel als Environment-Object ein,
    //          das wir in QuestLogDashboardView via .environmentObject(...) übergeben haben.
    @EnvironmentObject var characterVM: CharacterViewModel
    
    var quest: Quest
    
    @State private var title: String
    @State private var description: String
    @State private var status: String
    @State private var reward: String
    
    @State private var showAssignCharactersSheet = false
    
    init(quest: Quest, questLogVM: QuestLogViewModel) {
        self.quest = quest
        self._questLogVM = ObservedObject(wrappedValue: questLogVM)
        
        _title = State(initialValue: quest.title)
        _description = State(initialValue: quest.description)
        _status = State(initialValue: quest.status)
        _reward = State(initialValue: quest.reward ?? "")
    }
    
    var body: some View {
        Form {
            Section("Quest-Details") {
                TextField("Titel", text: $title)
                TextField("Beschreibung", text: $description)
                
                Picker("Status", selection: $status) {
                    Text("Aktiv").tag("aktiv")
                    Text("Abgeschlossen").tag("abgeschlossen")
                }
                .pickerStyle(.segmented)
                
                TextField("Belohnung", text: $reward)
            }
            
            if let creatorName = quest.creatorDisplayName {
                Section("Erstellt von") {
                    Text(creatorName)
                        .font(.headline)
                }
            }
            
            Section("Zugewiesene Charaktere") {
                // Hier zeigen wir statt ID -> Name
                if let assignedCharacterIds = quest.assignedCharacterIds,
                   !assignedCharacterIds.isEmpty {
                    
                    ForEach(assignedCharacterIds, id: \.self) { charId in
                        
                        // Versuche, diesen Charakter in characterVM zu finden
                        if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                            Text(foundChar.name)  // <-- Name statt "Character ID"
                        } else {
                            // Fallback, wenn wir ihn nicht gefunden haben
                            Text("Unbekannter Charakter (ID: \(charId))")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("Keine Charaktere zugewiesen.")
                        .foregroundColor(.gray)
                }
                
                Button("Charaktere zuweisen") {
                    showAssignCharactersSheet = true
                }
            }
            
            Section {
                Button("Speichern") {
                    let updatedQuest = Quest(
                        id: quest.id,
                        title: title,
                        description: description,
                        status: status,
                        createdAt: quest.createdAt,
                        userId: quest.userId,
                        reward: reward.isEmpty ? nil : reward,
                        creatorDisplayName: quest.creatorDisplayName,
                        assignedCharacterIds: quest.assignedCharacterIds
                    )
                    questLogVM.updateQuest(updatedQuest)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Löschen", role: .destructive) {
                    questLogVM.deleteQuest(quest)
                    dismiss()
                }
            }
        }
        .navigationTitle("Quest bearbeiten")
        .sheet(isPresented: $showAssignCharactersSheet) {
            // Bei Bedarf das selbe characterVM für die AssignCharactersView
            AssignCharactersView(quest: quest)
                .environmentObject(questLogVM)
                .environmentObject(characterVM)
                .environmentObject(userViewModel)
        }
    }
}
