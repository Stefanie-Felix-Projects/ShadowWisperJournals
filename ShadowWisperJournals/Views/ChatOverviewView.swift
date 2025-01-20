//
//  ChatOverviewView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct ChatOverviewView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @StateObject private var chatVM = ChatViewModel()
    @StateObject private var characterVM = CharacterViewModel()
    
    @State private var showNewChatSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                VStack {
                    TextField("Chats suchen...", text: $chatVM.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(chatVM.filteredChats) { chat in
                            NavigationLink(
                                destination: ChatDetailView(chatVM: chatVM, chat: chat)
                                    .environmentObject(userViewModel)
                            ) {
                                let participantData = participantProfiles(chat.participants)
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: -10) {
                                        ForEach(Array(participantData.prefix(2).enumerated()), id: \.offset) { _, data in
                                            profileImageView(urlString: data.1)
                                        }
                                    }
                                    .padding(.trailing, 8)
                                    
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
                    
                    Button("Neuen Chat starten") {
                        showNewChatSheet = true
                    }
                    .padding(.vertical, 8)
                }
                .background(Color.clear)
            }
            .navigationTitle("Chat-Übersicht")
            .background(Color.clear)
            .onAppear {
                characterVM.fetchAllCharacters()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let userId = userViewModel.userId {
                        let myCharIDs = characterVM.characters
                            .filter { $0.userId == userId }
                            .map { $0.id ?? "" }
                        chatVM.fetchChatsForCurrentUser(allMyCharIDs: myCharIDs)
                    }
                }
            }
            .onDisappear {
                chatVM.removeChatsListener()
            }
            .sheet(isPresented: $showNewChatSheet) {
                ZStack {
                    AnimatedBackgroundView(colors: AppColors.gradientColors)
                        .ignoresSafeArea()
                    
                    NewChatView(chatVM: chatVM) {
                    }
                    .environmentObject(userViewModel)
                    .background(Color.clear)
                }
                .presentationBackground(.clear)
            }
        }
    }
    
    private func participantProfiles(_ participantCharIds: [String]) -> [(String, String?)] {
        participantCharIds.map { charId -> (String, String?) in
            if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                return (foundChar.name, foundChar.profileImageURL)
            } else {
                return ("Unknown", nil)
            }
        }
    }
    
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
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.gray)
        }
    }
}
