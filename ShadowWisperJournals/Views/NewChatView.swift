//
//  NewChatView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 `NewChatView` ermöglicht das Erstellen eines neuen Chats zwischen
 zwei Charakteren. Dabei wählt der/die Benutzer:in einen eigenen
 Charakter und einen fremden Charakter aus. Optionale erste
 Nachricht kann hinzugefügt werden.
 
 - Erlaubt das Filtern fremder Charaktere über eine Suchleiste.
 - Überprüft, ob ein Chat zwischen den beiden Charakteren bereits existiert.
 - Falls ja, wird statt eines neuen Chats ein Alert angezeigt und
 der bereits existierende Chat geöffnet.
 - Falls nicht, wird ein neuer Chat angelegt und ggf. eine
 erste Nachricht versendet.
 */
struct NewChatView: View {
    
    // MARK: - Environment und ObservedObject
    
    /// Ermöglicht das Schließen (Dismiss) der aktuellen View.
    @Environment(\.dismiss) var dismiss
    
    /**
     Das ViewModel für Chats. Zuständig für:
     - Erstellen/Überprüfen neuer Chats
     - Senden der ersten Nachricht
     */
    @ObservedObject var chatVM: ChatViewModel
    
    /**
     Callback, der aufgerufen wird, wenn das Anlegen
     (oder Öffnen) eines Chats erfolgreich abgeschlossen wurde.
     */
    let onSuccess: (() -> Void)?
    
    /// Liefert Informationen zum aktuell eingeloggten Benutzer (z.B. userId).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    /// Das Character-ViewModel zum Laden aller Charaktere.
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - Auswahlzustände
    
    /// Der ID des ausgewählten, eigenen Charakters.
    @State private var mySelectedCharId: String? = nil
    
    /// Die ID des ausgewählten, fremden Charakters.
    @State private var otherSelectedCharId: String? = nil
    
    // MARK: - Weitere Eingaben
    
    /// Suchtext für das Filtern fremder Charaktere in der Liste.
    @State private var searchText: String = ""
    
    /// Text der optionalen, ersten Nachricht.
    @State private var initialMessage: String = ""
    
    // MARK: - UI-Zustände
    
    /// Steuert, ob ein Alert angezeigt wird, falls es schon einen existierenden Chat gibt.
    @State private var showExistingChatAlert: Bool = false
    
    /// Hält den eventuell bereits existierenden Chat, falls einer gefunden wird.
    @State private var existingChat: Chat? = nil
    
    // MARK: - Abgeleitete Listen
    
    /**
     Liste der Charaktere, die zum aktuell eingeloggten Nutzer gehören
     (d. h. "meine" Charaktere).
     */
    private var myCharacters: [Character] {
        guard let userId = userViewModel.userId else { return [] }
        return characterVM.characters.filter { $0.userId == userId }
    }
    
    /**
     Liste aller Charaktere, die nicht zum aktuell eingeloggten Nutzer gehören
     (d. h. "fremde" Charaktere).
     */
    private var otherCharacters: [Character] {
        guard let userId = userViewModel.userId else { return characterVM.characters }
        return characterVM.characters.filter { $0.userId != userId }
    }
    
    // MARK: - Body
    
    /**
     Der View-Aufbau erfolgt mit einem `NavigationStack` und einem `Form`:
     1. Auswahl des eigenen Charakters
     2. Auswahl eines fremden Charakters (mit Suchfeld)
     3. Optional: Erste Nachricht
     4. Button zum Erstellen des Chats, inkl. Prüfung auf bereits existierenden Chat
     */
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Eigener Charakter
                Section("Mit welchem meiner Charaktere schreibe ich?") {
                    List(myCharacters, id: \.id) { ch in
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
                
                // MARK: Fremder Charakter
                Section("Wen möchtest du kontaktieren?") {
                    TextField("Suche nach fremden Charakter...", text: $searchText)
                    
                    let filteredOthers = otherCharacters.filter { char in
                        if searchText.isEmpty { return true }
                        return char.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    List(filteredOthers, id: \.id) { ch in
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
                
                // MARK: Erste Nachricht
                Section("Erste Nachricht (optional)") {
                    TextField("Hey, wie geht's?", text: $initialMessage)
                }
                
                // MARK: Button "Chat erstellen"
                Section {
                    Button("Chat erstellen") {
                        createChatOrOpenExisting()
                    }
                    // Button deaktivieren, wenn keine Auswahl getroffen wurde
                    .disabled(mySelectedCharId == nil || otherSelectedCharId == nil)
                }
            }
            // Layout-Anpassungen
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Neuen Chat starten")
            // Toolbar: Abbrechen-Button
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            // Alert, falls Chat bereits existiert
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
                // Beim Erscheinen alle Charaktere laden
                characterVM.fetchAllCharacters()
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - Logikfunktionen
    
    /**
     Versucht, einen neuen Chat zwischen den ausgewählten Charakteren zu erstellen.
     Wenn bereits ein Chat existiert, wird dieser stattdessen geöffnet.
     */
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
                // Chat existiert bereits
                self.existingChat = existingChat
                self.showExistingChatAlert = true
            } else {
                // Neuer Chat wurde erfolgreich angelegt
                dismiss()
                onSuccess?()
            }
        }
    }
    
    /**
     Öffnet den bereits existierenden Chat und sendet ggf.
     die initiale Nachricht, falls diese gesetzt ist.
     
     - Parameter chat: Der bereits existierende Chat, der geöffnet werden soll.
     */
    private func navigateToChatDetail(chat: Chat) {
        dismiss()
        
        // Kleiner Delay, um das Dismiss sauber abzuschließen,
        // bevor weitere Aktionen erfolgen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            chatVM.fetchMessages(for: chat.id ?? "")
            
            // Falls der Nutzer bereits einen Text eingegeben hat, sende ihn nun
            if !initialMessage.isEmpty {
                chatVM.sendMessage(to: chat, senderCharId: mySelectedCharId ?? "", text: initialMessage)
            }
            
            // Rufe den Erfolgs-Callback auf
            onSuccess?()
        }
    }
}
