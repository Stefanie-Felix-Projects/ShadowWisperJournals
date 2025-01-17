//
//  QuestLogDashboardView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

struct QuestLogDashboardView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @StateObject private var questLogVM = QuestLogViewModel()
    @StateObject private var characterVM = CharacterViewModel()
    
    @State private var showNewQuestSheet = false
    
    var body: some View {
        VStack {
            filterSection
            
            List {
                Section("Erstellt von mir") {
                    ForEach(filteredMine) { quest in
                        NavigationLink(
                            destination: QuestDetailView(
                                quest: quest, questLogVM: questLogVM
                            )
                            .environmentObject(userViewModel)
                            .environmentObject(characterVM)
                        ) {
                            questRow(quest)
                        }
                    }
                }
                
                Section("Zugewiesen") {
                    ForEach(filteredAssigned) { quest in
                        NavigationLink(
                            destination: QuestDetailView(
                                quest: quest, questLogVM: questLogVM
                            )
                            .environmentObject(userViewModel)
                            .environmentObject(characterVM)
                        ) {
                            questRow(quest)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("QuestLog Dashboard")
        .toolbar {
            Button {
                showNewQuestSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .onAppear {
            characterVM.fetchAllCharacters()
            questLogVM.fetchAllQuests()
        }
        .sheet(isPresented: $showNewQuestSheet) {
            AddQuestView(
                questLogVM: questLogVM,
                userId: userViewModel.userId ?? ""
            )
            .environmentObject(userViewModel)
            .environmentObject(characterVM)
        }
    }
    
    @ViewBuilder
    private func questRow(_ quest: Quest) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(quest.title)
                .font(.headline)
            
            if let creatorName = quest.creatorDisplayName {
                Text("Erstellt von: \(creatorName)")
                    .font(.subheadline)
            }
            
            Text(
                "Status: \(quest.status), Erstellt am \(quest.createdAt.formatted(.dateTime.day().month().year()))"
            )
            .font(.subheadline)
            .foregroundColor(.gray)
        }
    }
    
    private var filteredMine: [Quest] {
        let uid = userViewModel.userId ?? ""
        return filteredQuestsForCurrentUser.filter { $0.userId == uid }
    }
    
    private var filteredAssigned: [Quest] {
        let uid = userViewModel.userId ?? ""
        return filteredQuestsForCurrentUser.filter { $0.userId != uid }
    }
    
    private var filteredQuestsForCurrentUser: [Quest] {
        guard let uid = userViewModel.userId else { return [] }
        
        let myCharacterIDs = characterVM.characters.compactMap { $0.id }
        let allQuests = questLogVM.quests
        
        let visibleQuests = allQuests.filter { quest in
            let isOwner = (quest.userId == uid)
            let assignedIds = quest.assignedCharacterIds ?? []
            let isAssignedToMe = !assignedIds.isEmpty && assignedIds.contains(where: myCharacterIDs.contains)
            return isOwner || isAssignedToMe
        }
        
        return visibleQuests.filter { quest in
            let isInRange = (quest.createdAt >= questLogVM.startDate &&
                             quest.createdAt <= questLogVM.endDate)
            
            switch questLogVM.selectedStatus {
            case "aktiv":
                return quest.status == "aktiv" && isInRange
            case "abgeschlossen":
                return quest.status == "abgeschlossen" && isInRange
            default:
                return isInRange
            }
        }
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            Picker("Status", selection: $questLogVM.selectedStatus) {
                Text("Alle").tag("alle")
                Text("Aktiv").tag("aktiv")
                Text("Abgeschlossen").tag("abgeschlossen")
            }
            .pickerStyle(.segmented)
            
            HStack {
                DatePicker(
                    "Von:", selection: $questLogVM.startDate,
                    displayedComponents: .date
                )
                DatePicker(
                    "Bis:", selection: $questLogVM.endDate,
                    displayedComponents: .date
                )
            }
            .font(.footnote)
            .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}
