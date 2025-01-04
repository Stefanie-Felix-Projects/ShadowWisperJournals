//
//  QuestDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

// MARK: - QuestDetailView
struct QuestDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @StateObject private var questLogVM = QuestLogViewModel()
    
    var quest: Quest
    
    // Editierbare Felder
    @State private var title: String
    @State private var description: String
    @State private var status: String
    @State private var reward: String
    
    init(quest: Quest) {
        self.quest = quest
        // Initialwerte setzen
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
            
            Section {
                Button("Speichern") {
                    let updatedQuest = Quest(
                        id: quest.id,
                        title: title,
                        description: description,
                        status: status,
                        createdAt: quest.createdAt,
                        userId: quest.userId,
                        reward: reward.isEmpty ? nil : reward
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
        .onAppear {
            // Damit wir im questLogVM überhaupt was haben (z.B. if needed)
            if let uid = userViewModel.userId {
                questLogVM.fetchQuests(for: uid)
            }
        }
    }
}
