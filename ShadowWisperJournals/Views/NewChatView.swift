//
//  NewChatView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct NewChatView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var chatVM: ChatViewModel
    
    let onSuccess: (() -> Void)?
    
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    @StateObject private var characterVM = CharacterViewModel()
    
    @State private var mySelectedCharId: String? = nil
    @State private var otherSelectedCharId: String? = nil
    
    @State private var searchText: String = ""
    @State private var initialMessage: String = ""
    @State private var showExistingChatAlert: Bool = false
    @State private var existingChat: Chat? = nil
    
    private var myCharacters: [Character] {
        guard let userId = userViewModel.userId else { return [] }
        return characterVM.characters.filter { $0.userId == userId }
    }
    
    private var otherCharacters: [Character] {
        guard let userId = userViewModel.userId else { return characterVM.characters }
        return characterVM.characters.filter { $0.userId != userId }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Mit welchem meiner Charaktere schreibe ich?") {
                    List(myCharacters, id: \ .id) { ch in
                        SelectableCharacterRow(
                            character: ch,
                            isSelected: mySelectedCharId == ch.id,
                            toggleSelection: {
                                if mySelectedCharId == ch.id {
                                    mySelectedCharId = nil
                                } else {
                                    mySelectedCharId = ch.id
                                }
                            }
                        )
                    }
                }
                
                Section("Wen möchtest du kontaktieren?") {
                    TextField("Suche nach fremden Charakter...", text: $searchText)
                    
                    let filteredOthers = otherCharacters.filter { char in
                        if searchText.isEmpty { return true }
                        return char.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    List(filteredOthers, id: \ .id) { ch in
                        SelectableCharacterRow(
                            character: ch,
                            isSelected: otherSelectedCharId == ch.id,
                            toggleSelection: {
                                if otherSelectedCharId == ch.id {
                                    otherSelectedCharId = nil
                                } else {
                                    otherSelectedCharId = ch.id
                                }
                            }
                        )
                    }
                }
                
                Section("Erste Nachricht (optional)") {
                    TextField("Hey, wie geht's?", text: $initialMessage)
                }
                
                Section {
                    Button("Chat erstellen") {
                        createChatOrOpenExisting()
                    }
                    .disabled(mySelectedCharId == nil || otherSelectedCharId == nil)
                }
            }
            .navigationTitle("Neuen Chat starten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .alert(isPresented: $showExistingChatAlert) {
                Alert(
                    title: Text("Chat existiert bereits"),
                    message: Text("Ein Chat zwischen diesen Charakteren existiert bereits. Er wird geöffnet."),
                    dismissButton: .default(Text("OK"), action: {
                        if let existingChat = existingChat {
                            navigateToChatDetail(chat: existingChat)
                        }
                    })
                )
            }
            .onAppear {
                characterVM.fetchAllCharacters()
            }
        }
    }
    
    private func createChatOrOpenExisting() {
        guard let myCharId = mySelectedCharId else { return }
        guard let otherCharId = otherSelectedCharId else { return }
        
        let participants = [myCharId, otherCharId]
        
        chatVM.createNewChat(
            participants: participants,
            initialMessage: initialMessage,
            senderCharId: myCharId
        ) { chat in
            if let existingChat = chat {
                self.existingChat = existingChat
                self.showExistingChatAlert = true
            } else {
                dismiss()
                onSuccess?()
            }
        }
    }
    
    private func navigateToChatDetail(chat: Chat) {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            chatVM.fetchMessages(for: chat.id ?? "")
            if !initialMessage.isEmpty {
                chatVM.sendMessage(to: chat, senderCharId: mySelectedCharId ?? "", text: initialMessage)
            }
            onSuccess?()
        }
    }
}
