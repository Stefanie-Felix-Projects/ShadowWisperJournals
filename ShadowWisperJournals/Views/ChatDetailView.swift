//
//  ChatDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct ChatDetailView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    @StateObject private var chatVM = ChatViewModel()
    
    let chat: Chat
    
    @State private var newMessageText: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    
                    ForEach(chatVM.messages) { message in
                        
                        if message.senderId == userViewModel.userId {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(message.text)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                    
                                    if isMessageReadByAll(message: message, chat: chat) {
                                        Text("Gelesen von allen")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    } else if message.readBy.contains(userViewModel.userId ?? "") {
                                        Text("Gelesen von dir")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                        } else {
                            VStack(alignment: .leading) {
                                Text(message.text)
                                    .padding(8)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onAppear {
                                if !message.readBy.contains(userViewModel.userId ?? "") {
                                    chatVM.markMessageAsRead(
                                        message,
                                        by: userViewModel.userId ?? "",
                                        in: chat.id ?? ""
                                    )
                                }
                            }
                        }
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
                .disabled(newMessageText.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat Details")
        .onAppear {
            if let chatId = chat.id {
                chatVM.fetchMessages(for: chatId)
            }
        }
        .onDisappear {
            chatVM.removeMessagesListener()
        }
    }
    
    private func sendMessage() {
        guard let userId = userViewModel.userId else { return }
        chatVM.sendMessage(to: chat, senderId: userId, text: newMessageText)
        newMessageText = ""
    }
    
    private func isMessageReadByAll(message: ChatMessage, chat: Chat) -> Bool {
        for participant in chat.participants {
            if !message.readBy.contains(participant) {
                return false
            }
        }
        return true
    }
}
