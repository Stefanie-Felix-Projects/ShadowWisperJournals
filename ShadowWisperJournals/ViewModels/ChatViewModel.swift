//
//  ChatViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import Foundation
import FirebaseFirestore
import Combine

class ChatViewModel: ObservableObject {
    
    @Published var chats: [Chat] = []
    @Published var messages: [ChatMessage] = []
    @Published var searchText: String = ""
    
    private let db = Firestore.firestore()
    private var chatsListener: ListenerRegistration?
    private var messagesListener: ListenerRegistration?
    
    func fetchChats(for userId: String) {
        removeChatsListener()
        
        chatsListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Laden der Chats: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.chats = documents.compactMap {
                        try? $0.data(as: Chat.self)
                    }
                }
            }
    }
    
    func removeChatsListener() {
        chatsListener?.remove()
        chatsListener = nil
    }
    
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter { chat in
                let matchLastMessage = chat.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchParticipantIds = chat.participants.contains { $0.localizedCaseInsensitiveContains(searchText) }
                return matchLastMessage || matchParticipantIds
            }
        }
    }
    
    func fetchMessages(for chatId: String) {
        removeMessagesListener()
        
        messagesListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Laden der Nachrichten: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.messages = documents.compactMap {
                        try? $0.data(as: ChatMessage.self)
                    }
                }
            }
    }
    
    func removeMessagesListener() {
        messagesListener?.remove()
        messagesListener = nil
    }
    
    func sendMessage(to chat: Chat, senderId: String, text: String) {
        guard let chatId = chat.id else { return }
        
        let newMessage = ChatMessage(
            id: nil,
            senderId: senderId,
            text: text,
            createdAt: Date(),
            readBy: [senderId]
        )
        
        do {
            let chatDocRef = db.collection("chats").document(chatId)
            let messagesRef = chatDocRef.collection("messages")
            
            _ = try messagesRef.addDocument(from: newMessage)
            
            try chatDocRef.setData([
                "lastMessage": text,
                "updatedAt": Date()
            ], merge: true)
            
            let otherParticipants = chat.participants.filter { $0 != senderId }
            sendNotificationToUsers(otherParticipants, message: text)
            
        } catch {
            print("Fehler beim Senden der Nachricht: \(error.localizedDescription)")
        }
    }
    
    func markMessageAsRead(_ message: ChatMessage, by userId: String, in chatId: String) {
        guard let messageId = message.id else { return }
        if message.readBy.contains(userId) { return }
        
        var updatedMessage = message
        updatedMessage.readBy.append(userId)
        
        do {
            try db.collection("chats").document(chatId)
                .collection("messages").document(messageId)
                .setData(from: updatedMessage, merge: true)
        } catch {
            print("Fehler beim Markieren als gelesen: \(error.localizedDescription)")
        }
    }
    
    func createNewChat(participants: [String], initialMessage: String?, senderId: String) {
        let now = Date()
        let chat = Chat(
            id: nil,
            participants: participants,
            lastMessage: initialMessage,
            updatedAt: now
        )
        
        do {
            let ref = try db.collection("chats").addDocument(from: chat)
            if let msg = initialMessage, !msg.isEmpty {
                let message = ChatMessage(
                    id: nil,
                    senderId: senderId,
                    text: msg,
                    createdAt: now,
                    readBy: [senderId]
                )
                try ref.collection("messages").addDocument(from: message)
            }
        } catch {
            print("Fehler beim Erstellen des Chats: \(error.localizedDescription)")
        }
    }
    
    func sendNotificationToUsers(_ userIds: [String], message: String) {
        print("Sende Benachrichtigung an \(userIds.joined(separator: ",")) mit Inhalt: \(message)")
    }
}
