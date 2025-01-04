//
//  AddQuestView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

// MARK: - AddQuestView
struct AddQuestView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var questLogVM: QuestLogViewModel
    let userId: String
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: String = "aktiv"
    @State private var reward: String = ""
    
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
                
                Button("Quest hinzufügen") {
                    guard !title.isEmpty, !description.isEmpty else { return }
                    questLogVM.addQuest(
                        title: title,
                        description: description,
                        status: status,
                        reward: reward.isEmpty ? nil : reward,
                        userId: userId
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
