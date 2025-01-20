//
//  ChatDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct ChatDetailView: View {
    @ObservedObject var chatVM: ChatViewModel
    @StateObject private var characterVM = CharacterViewModel()
    
    let chat: Chat
    @State private var newMessageText: String = ""
    
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    private var myCharIdInThisChat: String? {
        guard let userId = userViewModel.userId else { return nil }
        let myChars = characterVM.characters.filter { $0.userId == userId }
        return myChars.first(where: { chat.participants.contains($0.id ?? "") })?.id
    }
    
    private var messageViews: [AnyView] {
        chatVM.messages.map { msg in
            let allHaveRead = isMessageReadByAll(message: msg, chat: chat)
            let readByMe = myCharIdInThisChat.map { msg.readBy.contains($0) } ?? false
            let isMine = (msg.senderId == myCharIdInThisChat)
            
            let subview = MessageBubbleView(
                message: msg,
                isMine: isMine,
                allHaveRead: allHaveRead,
                readByMe: readByMe,
                onAppearAction: {
                    guard !isMine, let me = myCharIdInThisChat else { return }
                    if !msg.readBy.contains(me) {
                        chatVM.markMessageAsRead(msg, by: me, in: chat.id ?? "")
                    }
                }
            )
            return AnyView(subview)
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messageViews.indices, id: \.self) { i in
                            messageViews[i]
                        }
                    }
                    .padding()
                }
                
                HStack {
                    TextField("Nachricht eingeben", text: $newMessageText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .disabled(newMessageText.isEmpty || myCharIdInThisChat == nil)
                }
                .padding()
            }
        }
        .navigationTitle("Chat Details")
        .onAppear {
            if let chatId = chat.id {
                chatVM.fetchMessages(for: chatId)
            }
            characterVM.fetchAllCharacters()
        }
        .onDisappear {
            chatVM.removeMessagesListener()
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    private func sendMessage() {
        guard let myCharId = myCharIdInThisChat else { return }
        chatVM.sendMessage(to: chat, senderCharId: myCharId, text: newMessageText)
        newMessageText = ""
    }
    
    private func isMessageReadByAll(message: ChatMessage, chat: Chat) -> Bool {
        for participantCharId in chat.participants {
            if !message.readBy.contains(participantCharId) {
                return false
            }
        }
        return true
    }
}
