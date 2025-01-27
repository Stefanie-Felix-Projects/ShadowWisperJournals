//
//  ChatDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 `ChatDetailView` ist eine Detailansicht für einen bestimmten Chat.
 
 Sie zeigt alle Nachrichten (`ChatMessage`) an und ermöglicht das Schreiben neuer
 Nachrichten. Innerhalb der Ansicht wird geprüft, ob eine Nachricht von dem
 Charakter des aktuell eingeloggten Nutzers stammt, und ob alle Teilnehmer
 die jeweilige Nachricht bereits gelesen haben.
 
 **Wichtige Funktionen**:
 - Nachrichten laden (`fetchMessages`)
 - Neue Nachricht senden (`sendMessage`)
 - Gelesen-Status aktualisieren (`markMessageAsRead`)
 */
struct ChatDetailView: View {
    
    // MARK: - ObservedObjects
    
    /// Das `ChatViewModel` verwaltet alle Chat-spezifischen Daten wie Nachrichten und das Senden/Laden.
    @ObservedObject var chatVM: ChatViewModel
    
    /// Das `CharacterViewModel` verwaltet alle Charakterdaten; wird hier lokal verwendet, um den
    /// Charakter des aktuellen Nutzers im Chat zu identifizieren.
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - Eingaben
    
    /// Der Chat, dessen Nachrichten angezeigt werden sollen.
    let chat: Chat
    
    /// Textfeld-Eingabe für neue Nachrichten.
    @State private var newMessageText: String = ""
    
    // MARK: - Environment
    
    /// Liefert Informationen zum aktuell eingeloggten Benutzer (z.B. `userId`).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - Berechnete Eigenschaften
    
    /**
     Liefert die ID des Charakters, der zum aktuell eingeloggten Benutzer in diesem Chat gehört.
     
     Dafür werden alle Charaktere des Nutzers gefiltert und geprüft, ob deren ID im
     `chat.participants`-Array enthalten ist.
     */
    private var myCharIdInThisChat: String? {
        guard let userId = userViewModel.userId else { return nil }
        let myChars = characterVM.characters.filter { $0.userId == userId }
        return myChars.first(where: { chat.participants.contains($0.id ?? "") })?.id
    }
    
    /**
     Erzeugt eine Liste von `AnyView`, welche die `MessageBubbleView` für jede Nachricht
     enthält. Dabei wird geprüft:
     - `allHaveRead`: ob alle Teilnehmer die Nachricht gelesen haben
     - `readByMe`: ob der aktuelle Nutzer (bzw. dessen Charakter) die Nachricht gelesen hat
     - `isMine`: ob die Nachricht vom aktuellen Charakter stammt
     
     **Hinweis**: Der `onAppearAction` in `MessageBubbleView` markiert eine empfangene
     Nachricht als gelesen, wenn sie zuvor noch nicht gelesen wurde.
     */
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
                    // Nachricht nur markieren, wenn sie nicht von mir ist
                    // und mein Charakter sie noch nicht gelesen hat
                    guard !isMine, let me = myCharIdInThisChat else { return }
                    if !msg.readBy.contains(me) {
                        chatVM.markMessageAsRead(msg, by: me, in: chat.id ?? "")
                    }
                }
            )
            return AnyView(subview)
        }
    }
    
    // MARK: - Body
    
    /**
     Der Aufbau der View erfolgt mit einer vertikalen Anordnung:
     - Ein `ScrollView` zeigt alle Nachrichten in Form von `messageViews`.
     - Ein Eingabebereich (TextField + Button) am unteren Bildschirmrand ermöglicht das Versenden neuer Nachrichten.
     
     Beim Erscheinen der View (`.onAppear`) werden die Nachrichten für den konkreten Chat geladen.
     Bei Verlassen der View (`.onDisappear`) wird der Listener entfernt, um Ressourcen zu schonen.
     */
    var body: some View {
        ZStack {
            // Hintergrund mit animiertem Farbverlauf
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack {
                // MARK: Nachrichtenliste
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messageViews.indices, id: \.self) { i in
                            messageViews[i]
                        }
                    }
                    .padding()
                }
                
                // MARK: Eingabefeld und Sende-Button
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
                // Nachrichten laden, sobald die View erscheint
                chatVM.fetchMessages(for: chatId)
            }
            // Alle Charaktere laden, um den eigenen Charakter im Chat zu finden
            characterVM.fetchAllCharacters()
        }
        .onDisappear {
            // Listener entfernen, wenn die View verlassen wird
            chatVM.removeMessagesListener()
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    /**
     Sendet eine neue Nachricht im aktuellen Chat. Dabei wird das `senderCharId` auf
     den ermittelten Charakter des aktuellen Nutzers gesetzt und das Eingabefeld zurückgesetzt.
     */
    private func sendMessage() {
        guard let myCharId = myCharIdInThisChat else { return }
        chatVM.sendMessage(to: chat, senderCharId: myCharId, text: newMessageText)
        newMessageText = ""
    }
    
    /**
     Prüft, ob alle Teilnehmer (`chat.participants`) eine gegebene Nachricht gelesen haben
     (`message.readBy` enthält die jeweilige Charakter-ID).
     
     - Parameter message: Die zu prüfende Nachricht
     - Parameter chat: Der aktuelle Chat, der die Teilnehmerliste enthält
     - Returns: Ein Bool, der angibt, ob alle Teilnehmer die Nachricht gelesen haben
     */
    private func isMessageReadByAll(message: ChatMessage, chat: Chat) -> Bool {
        for participantCharId in chat.participants {
            if !message.readBy.contains(participantCharId) {
                return false
            }
        }
        return true
    }
}
