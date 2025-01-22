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
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    headerSection
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            if filteredMine.isEmpty && filteredAssigned.isEmpty {
                                // Keine Quests
                                Text("Keine Quests vorhanden")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            } else {
                                if !filteredMine.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Erstellt von mir")
                                            .font(.custom("SmoochSans-Bold", size: 22))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 4)
                                        
                                        TabView {
                                            ForEach(filteredMine) { quest in
                                                NavigationLink(
                                                    destination: QuestDetailView(
                                                        quest: quest,
                                                        questLogVM: questLogVM
                                                    )
                                                    .environmentObject(userViewModel)
                                                    .environmentObject(characterVM)
                                                ) {
                                                    questCard(quest)
                                                }
                                            }
                                        }
                                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                                        .frame(height: 320)
                                        .padding(.horizontal, 4)
                                        .padding(.top, 0)
                                    }
                                    .padding(.horizontal, 4)
                                }
                                
                                if !filteredAssigned.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Zugewiesen")
                                            .font(.custom("SmoochSans-Bold", size: 22))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 4)
                                        
                                        TabView {
                                            ForEach(filteredAssigned) { quest in
                                                NavigationLink(
                                                    destination: QuestDetailView(
                                                        quest: quest,
                                                        questLogVM: questLogVM
                                                    )
                                                    .environmentObject(userViewModel)
                                                    .environmentObject(characterVM)
                                                ) {
                                                    questCard(quest)
                                                }
                                            }
                                        }
                                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                                        .frame(height: 320)
                                        .padding(.horizontal, 4)
                                        .padding(.top, 0)
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            
                            Spacer(minLength: 16)
                        }
                        .padding(.horizontal, 12)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewQuestSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showNewQuestSheet) {
                ZStack {
                    AnimatedBackgroundView(colors: AppColors.gradientColors)
                        .ignoresSafeArea()
                    
                    AddQuestView(
                        questLogVM: questLogVM,
                        userId: userViewModel.userId ?? ""
                    )
                    .environmentObject(userViewModel)
                    .environmentObject(characterVM)
                }
                .presentationBackground(.clear)
            }
            .onAppear {
                characterVM.fetchAllCharacters()
                questLogVM.fetchAllQuests()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension QuestLogDashboardView {
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("ShadowWisperJournals")
                .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                .foregroundColor(AppColors.signalColor4)
                .padding(.top, 10)
            
            Text("QuestLog Dashboard")
                .font(.custom("SmoochSans-Bold", size: 25, relativeTo: .title))
                .foregroundColor(.white)
            
            filterSection
        }
        .padding(.horizontal, 16)
    }
    
    private var filterSection: some View {
        VStack(spacing: 8) {
            Picker("Status", selection: $questLogVM.selectedStatus) {
                Text("Alle").tag("alle")
                Text("Aktiv").tag("aktiv")
                Text("Abgeschlossen").tag("abgeschlossen")
            }
            .pickerStyle(.segmented)
            
            HStack {
                DatePicker("Von:", selection: $questLogVM.startDate, displayedComponents: .date)
                DatePicker("Bis:", selection: $questLogVM.endDate, displayedComponents: .date)
            }
            .font(.custom("SmoochSans-Regular", size: 20))
            .foregroundColor(.white)
        }
    }
}

extension QuestLogDashboardView {
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
            let isOwner = quest.userId == uid
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
}

extension QuestLogDashboardView {
    private func questCard(_ quest: Quest) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.signalColor1,
                            AppColors.signalColor5
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(
                    color: AppColors.signalColor1.opacity(0.8),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.custom("SmoochSans-Bold", size: 22))
                    .foregroundColor(.black)
                
                if let creatorName = quest.creatorDisplayName {
                    Text("Erstellt von: \(creatorName)")
                        .font(.custom("SmoochSans-Regular", size: 20))
                        .foregroundColor(.black.opacity(0.8))
                }
                
                Text("Status: \(quest.status)")
                    .font(.custom("SmoochSans-Regular", size: 20))
                    .foregroundColor(.black.opacity(0.8))
                
                Text("Erstellt am \(quest.createdAt.formatted(.dateTime.day().month().year()))")
                    .font(.custom("SmoochSans-Regular", size: 20))
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding()
        }
        .frame(height: 240)
        .padding(.vertical, 4)
    }
}
