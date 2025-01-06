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
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @StateObject private var characterVM = CharacterViewModel()
    
    @State private var searchText: String = ""
    @State private var selectedCharacterId: String? = nil
    
    @State private var initialMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Charakter auswählen") {
                    TextField("Suche nach Charakter...", text: $searchText)
                    
                    let filteredCharacters = characterVM.characters.filter { char in
                        if char.userId == userViewModel.userId {
                            return false
                        }
                        if searchText.isEmpty { return true }
                        return char.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    List(filteredCharacters) { character in
                        HStack {
                            Text(character.name)
                            Spacer()
                            if selectedCharacterId == character.id {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedCharacterId == character.id {
                                selectedCharacterId = nil
                            } else {
                                selectedCharacterId = character.id
                            }
                        }
                    }
                    .frame(minHeight: 200)
                }
                
                Section("Erste Nachricht (optional)") {
                    TextField("Hey, wie geht's?", text: $initialMessage)
                }
                
                Button("Chat erstellen") {
                    createChat()
                }
                .disabled(selectedCharacterId == nil)
            }
            .navigationTitle("Neuen Chat starten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let _ = userViewModel.userId {
                    characterVM.fetchAllCharacters()
                }
            }
        }
    }
    
    private func createChat() {
        guard let myUserId = userViewModel.userId else { return }
        guard let otherCharId = selectedCharacterId else { return }
        
        guard let otherChar = characterVM.characters.first(where: { $0.id == otherCharId }) else { return }
        
        let otherUserId = otherChar.userId
        
        let participants = [myUserId, otherUserId]
        
        chatVM.createNewChat(
            participants: participants,
            initialMessage: initialMessage,
            senderId: myUserId
        )
        
        dismiss()
    }
}
