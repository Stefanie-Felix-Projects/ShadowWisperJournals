//
//  QuestLogDashboardView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

/**
 `QuestLogDashboardView` bietet eine Übersicht über alle für den aktuellen Nutzer relevanten Quests.
 
 **Funktionen**:
 - Anzeige der erstellten (`filteredMine`) und zugewiesenen Quests (`filteredAssigned`)
 - Erstellen einer neuen Quest über ein Sheet (`showNewQuestSheet`)
 - Filtermöglichkeiten nach Status (Alle / Aktiv / Abgeschlossen) und Zeitraum (von/bis)
 - Navigieren zum Detail einer Quest (`QuestDetailView`)
 */
struct QuestLogDashboardView: View {
    
    // MARK: - Environment
    
    /// Liefert Informationen zum aktuell eingeloggten Nutzer (z. B. `userId`).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - StateObjects
    
    /**
     `QuestLogViewModel` verwaltet das Laden, Filtern und Manipulieren von Quests (CRUD).
     Wird hier lokal instanziert, da es primär für diesen Screen relevant ist.
     */
    @StateObject private var questLogVM = QuestLogViewModel()
    
    /**
     `CharacterViewModel` verwaltet alle Charaktere. Hier wird es verwendet, um herauszufinden,
     welche Quests dem aktuellen Nutzer zugeordnet sind (direkt oder via Charaktere).
     */
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - State
    
    /// Steuert die Anzeige des Sheets zum Erstellen einer neuen Quest.
    @State private var showNewQuestSheet = false
    
    // MARK: - Body
    
    /**
     Der Aufbau erfolgt über einen `NavigationStack` mit einem ZStack als Hintergrund.
     - Ein animierter Farbverlauf (`AnimatedBackgroundView`) bildet den Hintergrund.
     - Im Vordergrund befindet sich eine `VStack` mit Header und Filterfunktion,
     sowie einer `ScrollView` mit den gefilterten Quests (erscheinen in einem TabView).
     */
    var body: some View {
        NavigationStack {
            ZStack {
                // Animierter Hintergrund
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    
                    // Header und Filter (siehe Extension)
                    headerSection
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            // Wenn weder eigene noch zugewiesene Quests vorhanden sind
                            if filteredMine.isEmpty && filteredAssigned.isEmpty {
                                Text("Keine Quests vorhanden")
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                            } else {
                                // MARK: Quests "Erstellt von mir"
                                if !filteredMine.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Erstellt von mir")
                                            .font(.custom("SmoochSans-Bold", size: 22))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 4)
                                        
                                        // TabView mit eigenen Quests
                                        TabView {
                                            ForEach(filteredMine) { quest in
                                                NavigationLink(
                                                    destination: QuestDetailView(
                                                        quest: quest,
                                                        questLogVM: questLogVM
                                                    )
                                                    // EnvironmentObjects an die Detailansicht weitergeben
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
                                
                                // MARK: Quests "Zugewiesen"
                                if !filteredAssigned.isEmpty {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("Zugewiesen")
                                            .font(.custom("SmoochSans-Bold", size: 22))
                                            .foregroundColor(.white)
                                            .padding(.bottom, 4)
                                        
                                        // TabView mit zugewiesenen Quests
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
                        // Entfernt den Hintergrund der ScrollView
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            // MARK: Toolbar / Plus-Button
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
            // MARK: Neues Quest-Sheet
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
            // MARK: onAppear
            .onAppear {
                characterVM.fetchAllCharacters()
                questLogVM.fetchAllQuests()
            }
            // Leere NavigationTitle => Titel kann im Header erscheinen
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Header-Bereich
extension QuestLogDashboardView {
    /**
     `headerSection` enthält den Titel "ShadowWisperJournals", den Untertitel "QuestLog Dashboard"
     sowie den `filterSection` (Status-Picker, Datums-Picker).
     */
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
    
    /**
     `filterSection` enthält:
     - Einen Picker zum Auswählen des Status (Alle, Aktiv, Abgeschlossen)
     - Zwei DatePicker (für `startDate` und `endDate`) zur Einschränkung
     des Anzeigezeitraums für Quests.
     */
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

// MARK: - Filter-Logik
extension QuestLogDashboardView {
    /**
     `filteredMine`: Enthält alle Quests, die der aktuelle Nutzer angelegt hat.
     Hier wird überprüft, ob `quest.userId` mit der `userId` des aktuellen Nutzers übereinstimmt.
     */
    private var filteredMine: [Quest] {
        let uid = userViewModel.userId ?? ""
        return filteredQuestsForCurrentUser.filter { $0.userId == uid }
    }
    
    /**
     `filteredAssigned`: Enthält alle Quests, die nicht vom aktuellen Nutzer erstellt wurden,
     bei denen er aber durch einen seiner Charaktere (`assignedCharacterIds`) zugewiesen ist.
     */
    private var filteredAssigned: [Quest] {
        let uid = userViewModel.userId ?? ""
        return filteredQuestsForCurrentUser.filter { $0.userId != uid }
    }
    
    /**
     `filteredQuestsForCurrentUser`: Liefert Quests, die entweder vom aktuellen Nutzer
     erstellt wurden oder ihm durch seine Charaktere zugewiesen sind.
     
     **Filter**:
     - Zeitraum (zwischen `questLogVM.startDate` und `questLogVM.endDate`)
     - Status (Entweder "aktiv", "abgeschlossen" oder "alle")
     */
    private var filteredQuestsForCurrentUser: [Quest] {
        guard let uid = userViewModel.userId else { return [] }
        
        // Liste aller Charaktere-IDs, die dem aktuellen Nutzer gehören
        let myCharacterIDs = characterVM.characters.compactMap { $0.id }
        
        // Alle Quests aus dem ViewModel
        let allQuests = questLogVM.quests
        
        // Schritt 1: Nur Quests anzeigen, die dem Nutzer gehören oder zugewiesen sind
        let visibleQuests = allQuests.filter { quest in
            let isOwner = quest.userId == uid
            let assignedIds = quest.assignedCharacterIds ?? []
            let isAssignedToMe = !assignedIds.isEmpty && assignedIds.contains(where: myCharacterIDs.contains)
            return isOwner || isAssignedToMe
        }
        
        // Schritt 2: Filter nach Datum und Status
        return visibleQuests.filter { quest in
            // Prüfen, ob das Erstellungsdatum im ausgewählten Bereich liegt
            let isInRange = (quest.createdAt >= questLogVM.startDate &&
                             quest.createdAt <= questLogVM.endDate)
            
            // Status prüfen
            switch questLogVM.selectedStatus {
            case "aktiv":
                return quest.status == "aktiv" && isInRange
            case "abgeschlossen":
                return quest.status == "abgeschlossen" && isInRange
            default: // "alle"
                return isInRange
            }
        }
    }
}

// MARK: - Quest-Karten
extension QuestLogDashboardView {
    /**
     Stellt eine einzelne Quest als Karte dar (z. B. Titel, Ersteller, Status, Erstellungsdatum).
     */
    private func questCard(_ quest: Quest) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Hintergrund der Karte: farbiger Farbverlauf
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
            
            // Text-Infos
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
