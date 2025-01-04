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
    @State private var showNewQuestSheet = false
    
    var body: some View {
        VStack {
            filterSection
            
            List(questLogVM.filteredQuests) { quest in
                NavigationLink(destination: QuestDetailView(quest: quest)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quest.title)
                            .font(.headline)
                        Text("Status: \(quest.status), Erstellt am \(quest.createdAt.formatted(.dateTime.day().month().year()))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
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
            if let uid = userViewModel.userId {
                questLogVM.fetchQuests(for: uid)
            }
        }
        .sheet(isPresented: $showNewQuestSheet) {
            AddQuestView(questLogVM: questLogVM, userId: userViewModel.userId ?? "")
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
                DatePicker("Von:", selection: $questLogVM.startDate, displayedComponents: .date)
                DatePicker("Bis:", selection: $questLogVM.endDate, displayedComponents: .date)
            }
            .font(.footnote)
            .padding(.top, 4)
        }
        .padding(.horizontal)
    }
}

#Preview {
    QuestLogDashboardView()
}
