//
//  ChatViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// 

import Combine
import FirebaseFirestore
import Foundation

/// `ChatViewModel` ist eine ViewModel-Klasse zur Verwaltung von Chat-Daten und Nachrichten
/// in der ShadowWisperJournals-App. Sie stellt Methoden bereit, um Chats und Nachrichten
/// aus Firestore zu laden, zu aktualisieren und zu löschen sowie neue Chats zu erstellen.
class ChatViewModel: ObservableObject {
    // MARK: - Published Properties
    /// Eine Liste der geladenen Chats, die in der UI angezeigt wird.
    @Published var chats: [Chat] = []
    
    /// Eine Liste der Nachrichten eines spezifischen Chats.
    @Published var messages: [ChatMessage] = []
    
    /// Der aktuelle Suchtext für die Filterung von Chats.
    @Published var searchText: String = ""
    
    // MARK: - Private Properties
    /// Instanz von Firestore für die Datenbankinteraktion.
    private let db = Firestore.firestore()
    
    /// Firestore-Listener für Chats.
    private var chatsListener: ListenerRegistration?
    
    /// Firestore-Listener für Nachrichten.
    private var messagesListener: ListenerRegistration?
    
    // MARK: - Hilfsmethoden
    /// Erstellt einen sortierten Schlüssel aus den Teilnehmer-IDs, um Chats effizient zu identifizieren.
    /// - Parameter participantIDs: Die IDs der Chat-Teilnehmer.
    /// - Returns: Ein sortierter Schlüssel.
    private func sortedKey(for participantIDs: [String]) -> String {
        participantIDs.sorted().joined(separator: "|")
    }
    
    // MARK: - Chat-Methoden
    /// Löscht einen Chat und alle zugehörigen Nachrichten aus der Firestore-Datenbank.
    /// - Parameter chat: Der zu löschende Chat.
    func deleteChat(_ chat: Chat) {
        guard let chatId = chat.id else { return }
        
        let messagesRef = db.collection("chats").document(chatId).collection("messages")
        
        messagesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Fehler beim Abrufen der Nachrichten: \(error.localizedDescription)")
                return
            }
            
            // Löscht alle Nachrichten im Chat.
            snapshot?.documents.forEach { doc in
                doc.reference.delete { err in
                    if let err = err {
                        print("Fehler beim Löschen einer Nachricht: \(err.localizedDescription)")
                    }
                }
            }
            
            // Löscht den Chat selbst.
            self.db.collection("chats").document(chatId).delete { err in
                if let err = err {
                    print("Fehler beim Löschen des Chats: \(err.localizedDescription)")
                } else {
                    print("Chat \(chatId) erfolgreich gelöscht.")
                }
            }
        }
    }
    
    /// Lädt alle Chats, die mit den übergebenen Charakter-IDs verknüpft sind.
    /// - Parameter allMyCharIDs: Eine Liste von Charakter-IDs des aktuellen Benutzers.
    func fetchChatsForCurrentUser(allMyCharIDs: [String]) {
        removeChatsListener()
        
        chatsListener = db.collection("chats")
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Laden der Chats: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                let allChats = documents.compactMap {
                    try? $0.data(as: Chat.self)
                }
                let mySet = Set(allMyCharIDs)
                let filtered = allChats.filter { chat in
                    let participantSet = Set(chat.participants)
                    return !participantSet.isDisjoint(with: mySet)
                }
                
                DispatchQueue.main.async {
                    self.chats = filtered
                }
            }
    }
    
    /// Entfernt den Listener für Chats, um Ressourcen zu sparen.
    func removeChatsListener() {
        chatsListener?.remove()
        chatsListener = nil
    }
    
    /// Liefert eine gefilterte Liste von Chats basierend auf dem Suchtext.
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter { chat in
                let matchLastMessage = chat.lastMessage?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchParticipantIds = chat.participants.contains {
                    $0.localizedCaseInsensitiveContains(searchText)
                }
                return matchLastMessage || matchParticipantIds
            }
        }
    }
    
    // MARK: - Nachrichten-Methoden
    /// Lädt Nachrichten eines spezifischen Chats aus der Firestore-Datenbank.
    /// - Parameter chatId: Die ID des Chats, dessen Nachrichten abgerufen werden sollen.
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
    
    /// Entfernt den Listener für Nachrichten.
    func removeMessagesListener() {
        messagesListener?.remove()
        messagesListener = nil
    }
    
    /// Markiert eine Nachricht als gelesen, indem die Charakter-ID zur `readBy`-Liste hinzugefügt wird.
    func markMessageAsRead(_ message: ChatMessage, by charId: String, in chatId: String) {
        guard let messageId = message.id else { return }
        if message.readBy.contains(charId) { return }
        
        var updatedMessage = message
        updatedMessage.readBy.append(charId)
        
        do {
            try db.collection("chats").document(chatId)
                .collection("messages")
                .document(messageId)
                .setData(from: updatedMessage, merge: true)
        } catch {
            print("Fehler beim Markieren als gelesen: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Chat-Erstellung und Senden von Nachrichten
    /// Überprüft, ob ein Chat mit den angegebenen Teilnehmern existiert.
    func checkIfChatExists(participants: [String], completion: @escaping (Chat?) -> Void) {
        let key = sortedKey(for: participants)
        db.collection("chats")
            .whereField("participantsSortedKey", isEqualTo: key)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Fehler bei checkIfChatExists: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                guard let docs = snapshot?.documents, !docs.isEmpty else {
                    completion(nil)
                    return
                }
                let firstDoc = docs[0]
                let foundChat = try? firstDoc.data(as: Chat.self)
                completion(foundChat)
            }
    }
    
    /// Erstellt einen neuen Chat und fügt optional eine erste Nachricht hinzu.
    func createNewChat(
        participants: [String],
        initialMessage: String?,
        senderCharId: String,
        completion: @escaping (Chat?) -> Void
    ) {
        checkIfChatExists(participants: participants) { existingChat in
            if let existing = existingChat {
                completion(existing)
                return
            }
            
            let now = Date()
            let sortedKey = self.sortedKey(for: participants)
            
            let chat = Chat(
                id: nil,
                participants: participants,
                lastMessage: initialMessage,
                updatedAt: now,
                participantsSortedKey: sortedKey
            )
            
            do {
                let ref = try self.db.collection("chats").addDocument(from: chat)
                
                if let msg = initialMessage, !msg.isEmpty {
                    let message = ChatMessage(
                        id: nil,
                        senderId: senderCharId,
                        text: msg,
                        createdAt: now,
                        readBy: [senderCharId]
                    )
                    try ref.collection("messages").addDocument(from: message)
                }
                
                ref.getDocument { docSnap, error in
                    if let doc = docSnap, doc.exists {
                        let newChat = try? doc.data(as: Chat.self)
                        completion(newChat)
                    } else {
                        completion(nil)
                    }
                }
            } catch {
                print("Fehler beim Erstellen des Chats: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// Sendet eine Nachricht an einen bestehenden Chat und aktualisiert dessen Metadaten.
    func sendMessage(to chat: Chat, senderCharId: String, text: String) {
        guard let chatId = chat.id else { return }
        
        let newMessage = ChatMessage(
            id: nil,
            senderId: senderCharId,
            text: text,
            createdAt: Date(),
            readBy: [senderCharId]
        )
        
        do {
            let chatDocRef = db.collection("chats").document(chatId)
            let messagesRef = chatDocRef.collection("messages")
            
            _ = try messagesRef.addDocument(from: newMessage)
            
            chatDocRef.setData([
                "lastMessage": text,
                "updatedAt": Date()
            ], merge: true)
            
            let others = chat.participants.filter { $0 != senderCharId }
            sendNotificationToUsers(others, message: text)
        } catch {
            print("Fehler beim Senden der Nachricht: \(error.localizedDescription)")
        }
    }
    
    /// Sendet eine Benachrichtigung an die Teilnehmer eines Chats.
    /// - Parameter charIds: Die IDs der Charaktere, die benachrichtigt werden sollen.
    /// - Parameter message: Die Nachricht, die in der Benachrichtigung enthalten sein soll.
    func sendNotificationToUsers(_ charIds: [String], message: String) {
        print("Sende Benachrichtigung an \(charIds.joined(separator: ",")) mit Inhalt: \(message)")
    }
}
