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

    @State private var showNewChatSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Chats suchen...", text: $chatVM.searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                List(chatVM.filteredChats) { chat in
                    NavigationLink(destination: ChatDetailView(chat: chat)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                "Teilnehmer-IDs: \(chat.participants.joined(separator: ", "))"
                            )
                            .font(.headline)
                            Text(chat.lastMessage ?? "Keine Nachrichten")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(
                                "Aktualisiert am \(chat.updatedAt.formatted())"
                            )
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.plain)

                Button("Neuen Chat starten") {
                    showNewChatSheet = true
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("Chat-Übersicht")
            .onAppear {
                if let userId = userViewModel.userId {
                    chatVM.fetchChats(for: userId)
                }
            }
            .onDisappear {
                chatVM.removeChatsListener()
            }
            .sheet(isPresented: $showNewChatSheet) {
                NewChatView(chatVM: chatVM)
                    .environmentObject(userViewModel)
            }
        }
    }
}
