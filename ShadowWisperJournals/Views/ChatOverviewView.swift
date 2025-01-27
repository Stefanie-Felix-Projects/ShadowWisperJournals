//
//  ChatOverviewView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 `ChatOverviewView` dient als Übersicht aller aktiven Chats.
 
 - Zeigt eine Liste aller gefundenen Chats.
 - Ermöglicht das Löschen einzelner Chats via Swipe.
 - Ermöglicht das Starten eines neuen Chats in einem Sheet.
 
 **Voraussetzungen**:
 - Ein eingeloggter Nutzer (via `userViewModel`), dessen Charaktere geladen werden.
 - `ChatViewModel` zum Verwalten (Lesen/Schreiben) von Chats.
 - `CharacterViewModel` zum Laden und Zuordnen von Charakteren.
 */
struct ChatOverviewView: View {
    
    // MARK: - Environment
    
    /// Liefert Informationen zum aktuell angemeldeten Nutzer (z.B. `userId`).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - StateObject & ObservedObjects
    
    /**
     `ChatViewModel` verwaltet Chats, z.B. das Laden, Löschen oder
     Filtern (z.B. nach Suchtext).
     */
    @StateObject private var chatVM = ChatViewModel()
    
    /**
     `CharacterViewModel` verwaltet alle Charaktere. Hierüber wird
     festgestellt, welche Charakter-IDs zum aktuellen Nutzer gehören.
     */
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - State
    
    /// Steuert, ob das Sheet für das Erstellen eines neuen Chats angezeigt wird.
    @State private var showNewChatSheet = false
    
    // MARK: - Body
    
    /**
     Die Hauptansicht besteht aus einem `NavigationStack`, der eine Liste
     aller aktuell geladenen Chats anzeigt. Am unteren Bildschirmrand gibt es
     einen Button zum Starten eines neuen Chats.
     
     Beim Erscheinen werden die Charaktere geladen und anschließend
     die Chats des aktuellen Nutzers abgerufen (`fetchChatsForCurrentUser`).
     */
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund mit animiertem Farbverlauf
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                VStack {
                    // Suchfeld für Chats
                    TextField("Chats suchen...", text: $chatVM.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    // Liste gefilterter Chats
                    List {
                        ForEach(chatVM.filteredChats) { chat in
                            NavigationLink(
                                destination: ChatDetailView(chatVM: chatVM, chat: chat)
                                    .environmentObject(userViewModel)
                            ) {
                                let participantData = participantProfiles(chat.participants)
                                
                                HStack(spacing: 12) {
                                    // Profilbilder (bis zu 2) der Teilnehmer
                                    HStack(spacing: -10) {
                                        ForEach(Array(participantData.prefix(2).enumerated()), id: \.offset) { _, data in
                                            profileImageView(urlString: data.1)
                                        }
                                    }
                                    .padding(.trailing, 8)
                                    
                                    // Info-Bereich: Teilnehmerliste, letzter Chat-Text, Aktualisierungsdatum
                                    VStack(alignment: .leading, spacing: 4) {
                                        let joinedNames = participantData.map { $0.0 }.joined(separator: ", ")
                                        Text("Teilnehmer: \(joinedNames)")
                                            .font(.headline)
                                        
                                        Text(chat.lastMessage ?? "Keine Nachrichten")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text("Aktualisiert am \(chat.updatedAt.formatted())")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            // Swipe-Action zum Löschen eines Chats
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    chatVM.deleteChat(chat)
                                } label: {
                                    Text("Löschen")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    
                    // Button zum Starten eines neuen Chats
                    Button("Neuen Chat starten") {
                        showNewChatSheet = true
                    }
                    .padding(.vertical, 8)
                }
                .background(Color.clear)
            }
            .navigationTitle("Chat-Übersicht")
            .background(Color.clear)
            
            // MARK: onAppear
            .onAppear {
                // Lade alle Charaktere
                characterVM.fetchAllCharacters()
                
                // Warte kurz, bis Charaktere geladen sind, dann lade relevante Chats
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let userId = userViewModel.userId {
                        let myCharIDs = characterVM.characters
                            .filter { $0.userId == userId }
                            .map { $0.id ?? "" }
                        chatVM.fetchChatsForCurrentUser(allMyCharIDs: myCharIDs)
                    }
                }
            }
            
            // Stoppe das Lauschen auf Änderungen an Chats, wenn die View verschwindet
            .onDisappear {
                chatVM.removeChatsListener()
            }
            
            // MARK: Sheet: Neuen Chat erstellen
            .sheet(isPresented: $showNewChatSheet) {
                ZStack {
                    AnimatedBackgroundView(colors: AppColors.gradientColors)
                        .ignoresSafeArea()
                    
                    NewChatView(chatVM: chatVM) {
                        // Callback nach erfolgreicher Chat-Erstellung (falls benötigt)
                    }
                    .environmentObject(userViewModel)
                    .background(Color.clear)
                }
                .presentationBackground(.clear)
            }
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    /**
     Gibt ein Array von `(Name, ProfilbildURL?)` zurück, welches auf den
     Zeichenketten der Teilnehmer-IDs (`participantCharIds`) basiert.
     
     - Parameter participantCharIds: Die Charakter-IDs aller Teilnehmer
     - Returns: Array von Tupeln (Name, optionales ProfilbildURL)
     */
    private func participantProfiles(_ participantCharIds: [String]) -> [(String, String?)] {
        participantCharIds.map { charId -> (String, String?) in
            if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                return (foundChar.name, foundChar.profileImageURL)
            } else {
                return ("Unknown", nil)
            }
        }
    }
    
    /**
     Erzeugt eine View (Profilbild oder Platzhalter) basierend auf einer
     optionalen URL. Wird in der Liste für jeden Teilnehmer angezeigt.
     
     - Parameter urlString: URL des Profilbilds als String (optional)
     - Returns: `some View`
     */
    @ViewBuilder
    private func profileImageView(urlString: String?) -> some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 32, height: 32)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .shadow(radius: 1)
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            // Platzhalter, falls keine URL existiert
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
        }
    }
}
