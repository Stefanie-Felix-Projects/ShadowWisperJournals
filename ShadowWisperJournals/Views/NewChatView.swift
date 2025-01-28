//
//  NewChatView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 `NewChatView` ist eine `View`, welche den Benutzer in die Lage versetzt, einen neuen Chat zwischen zwei Charakteren zu erstellen.
 
 - Der Nutzer kann aus einer Liste seiner eigenen Charaktere einen auswählen.
 - Anschließend kann er einen fremden Charakter (von anderen Benutzern) auswählen.
 - Optional kann eine initiale Nachricht verfasst werden, die nach dem Erstellen des Chats direkt gesendet wird.
 
 Diese View behandelt außerdem den Fall, dass für die beiden gewählten Charaktere bereits ein Chat existiert: In diesem Fall wird statt eines neuen Chats einfach der bestehende Chat geöffnet.
*/
struct NewChatView: View {
    
    // MARK: - Environment- und ObservedObject-Variablen
    
    /// Ermöglicht das automatische Schließen der View (z. B. per "Abbrechen"-Button).
    @Environment(\.dismiss) var dismiss
    
    /**
     `chatVM` ist das ViewModel, das für die Verwaltung sämtlicher Chat-bezogener Daten und Vorgänge
     (Erstellen, Abrufen und Senden von Nachrichten) verantwortlich ist.
    */
    @ObservedObject var chatVM: ChatViewModel
    
    /**
     Ein optionaler Callback, der nach erfolgreicher Chaterstellung aufgerufen werden kann,
     um beispielsweise die übergeordnete View zu informieren.
    */
    let onSuccess: (() -> Void)?
    
    /**
     `userViewModel` stellt Informationen über den aktuell eingeloggten Nutzer bereit,
     insbesondere dessen `userId`. Über `@EnvironmentObject` wird das ViewModel
     zentral zur Verfügung gestellt.
    */
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    /**
     `characterVM` ist ein eigener State-Object, das Charaktere (sowohl eigene als auch fremde) verwaltet.
     Sobald die View erscheint, wird die Liste aller Charaktere geladen.
    */
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - Ausgewählte Charakter-IDs
    
    /// Speichert die ID des vom User gewählten eigenen Charakters (falls ausgewählt).
    @State private var mySelectedCharId: String? = nil
    
    /// Speichert die ID des vom User gewählten fremden Charakters (falls ausgewählt).
    @State private var otherSelectedCharId: String? = nil
    
    // MARK: - Suchtext und initiale Nachricht
    
    /**
     Suchtext, um in der Liste der fremden Charaktere zu filtern.
     Sobald der Nutzer hier tippt, wird die Liste der Charaktere gefiltert.
    */
    @State private var searchText: String = ""
    
    /**
     Text für die initiale Nachricht, die direkt beim Erstellen des Chats gesendet werden kann
     (Feld ist optional; kann auch leer bleiben).
    */
    @State private var initialMessage: String = ""
    
    // MARK: - State für Alert bei bereits bestehendem Chat
    
    /// Steuert das Anzeigen eines Alerts, falls ein Chat zwischen den beiden Charakteren bereits existiert.
    @State private var showExistingChatAlert: Bool = false
    
    /// Falls ein bereits existierender Chat gefunden wird, wird dieser hier zwischengespeichert, um ihn dann zu öffnen.
    @State private var existingChat: Chat? = nil
    
    // MARK: - Computed Properties für Listen der Charaktere
    
    /**
     Liefert eine gefilterte Liste der eigenen Charaktere zurück, basierend auf der `userId`.
     Falls keine `userId` vorhanden ist, wird ein leeres Array zurückgegeben.
    */
    private var myCharacters: [Character] {
        guard let userId = userViewModel.userId else { return [] }
        return characterVM.characters.filter { $0.userId == userId }
    }
    
    /**
     Liefert eine gefilterte Liste der fremden Charaktere zurück, d. h. solche,
     deren `userId` sich von der `userId` des aktuellen Nutzers unterscheidet.
     Falls keine `userId` vorhanden ist, werden alle Charaktere zurückgegeben.
     
     **Achtung**: Hier könnte man sich überlegen, ob man bei fehlender `userId`
     nicht besser ein leeres Array zurückgibt. Aktuell wird stattdessen das gesamte
     Character-Array genutzt, um wenigstens ein Verhalten zu bieten, falls `userId` = nil.
    */
    private var otherCharacters: [Character] {
        guard let userId = userViewModel.userId else { return characterVM.characters }
        return characterVM.characters.filter { $0.userId != userId }
    }
    
    // MARK: - Body
    
    /**
     Der Hauptinhalt der View, bestehend aus einem `NavigationStack` mit einem `Form`.
     
     - **Form**:
       - Eine Sektion zur Auswahl des eigenen Charakters.
       - Eine Sektion zur Auswahl des fremden Charakters mit Suchfeld.
       - Eine Sektion zur Eingabe einer ersten Nachricht.
       - Ein Button, um den Chat zu erstellen (oder den bestehenden zu öffnen).
    */
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Eigener Charakter
                Section("Mit welchem meiner Charaktere schreibe ich?") {
                    /**
                     Listet alle eigenen Charaktere des Users auf.
                     Für jeden Charakter wird eine Custom-Row `SelectableCharacterRow` genutzt,
                     die anzeigt, ob der Charakter ausgewählt ist und optional ein Bild bzw. Text darstellt.
                     Durch Antippen kann der Charakter ausgewählt oder wieder abgewählt werden.
                    */
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
                    /**
                     `TextField` zum Eingeben des Suchtexts, um die fremden Charaktere zu filtern.
                    */
                    TextField("Suche nach fremden Charakter...", text: $searchText)
                    
                    /**
                     Liste der anderen Charaktere, gefiltert anhand des `searchText`.
                     - Ist das Suchfeld leer, werden alle fremden Charaktere angezeigt.
                     - Enthält es einen Wert, wird nach dem Namen gefiltert (case-insensitive).
                    */
                    let filteredOthers = otherCharacters.filter { char in
                        if searchText.isEmpty { return true }
                        return char.name.localizedCaseInsensitiveContains(searchText)
                    }
                    
                    /**
                     Listet die gefilterten fremden Charaktere auf.
                     Ebenfalls als `SelectableCharacterRow`.
                    */
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
                    /**
                     `TextField` für eine optionale Nachricht, die direkt nach Erstellung des Chats gesendet wird.
                    */
                    TextField("Hey, wie geht's?", text: $initialMessage)
                }
                
                // MARK: Button "Chat erstellen"
                Section {
                    /**
                     Button zum Erstellen des Chats. Er ruft `createChatOrOpenExisting()` auf.
                     Ist deaktiviert, solange kein eigener und kein fremder Charakter ausgewählt sind.
                    */
                    Button("Chat erstellen") {
                        createChatOrOpenExisting()
                    }
                    .disabled(mySelectedCharId == nil || otherSelectedCharId == nil)
                }
            }
            /**
             `scrollContentBackground(.hidden)` und `background(Color.clear)` werden genutzt,
             um eventuell das Hintergrund-Layout anzupassen.
             Kann z. B. bei speziellen Designs oder Farbverläufen sinnvoll sein.
            */
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            
            /**
             Setzt den Titel der Navigationsleiste.
            */
            .navigationTitle("Neuen Chat starten")
            
            /**
             Fügt der Navigationsleiste einen `Abbrechen`-Button hinzu.
             Dieser nutzt das `dismiss()`-Environment, um die aktuelle View zu schließen.
            */
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            
            /**
             Alert, der erscheint, wenn `showExistingChatAlert == true`.
             - Zeigt an, dass bereits ein Chat existiert.
             - Klickt man auf "OK", wird direkt zum bestehenden Chat navigiert.
            */
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
            
            /**
             Lädt beim Erscheinen der View (z. B. nach dem Navigieren auf diese Seite) alle Charaktere.
             Dieser Aufruf sorgt dafür, dass `characterVM.characters` gefüllt wird.
            */
            .onAppear {
                characterVM.fetchAllCharacters()
            }
        }
        .background(Color.clear)
    }
    
    // MARK: - Logikfunktionen
    
    /**
     Prüft, ob ein Chat zwischen den ausgewählten Charakteren bereits existiert. Falls nicht,
     wird ein neuer Chat erstellt. Sobald der Server (bzw. das Firestore/Backend)
     zurückmeldet, ob der Chat existiert oder neu angelegt wurde, wird entsprechend reagiert:
     
     - **Bereits existierender Chat**:
       - Speichere den Chat in `existingChat`.
       - Setze `showExistingChatAlert = true`, damit der Alert angezeigt wird.
     
     - **Neuer Chat**:
       - Chat wurde erfolgreich erstellt.
       - Schließe die View mit `dismiss()`.
       - Rufe den optionalen Callback `onSuccess?()` auf.
     
     - **Fehlerfall**:
       - Falls kein Chat-Objekt zurückkommt, gib eine Fehlermeldung aus.
    */
    private func createChatOrOpenExisting() {
        guard let myCharId = mySelectedCharId else { return }
        guard let otherCharId = otherSelectedCharId else { return }
        
        let participants = [myCharId, otherCharId]
        
        /**
         Ruft die Funktion `createNewChat` aus `chatVM` auf, welche sich um die
         Chat-Erzeugung (oder -Überprüfung) kümmert.
         - `participants`: Array mit beiden CharIDs.
         - `initialMessage`: bei Bedarf zu sendender Eingangs-Text.
         - `senderCharId`: Der Char, von dem die Nachricht abgeschickt werden soll.
         - Completion: liefert `(chat, didExist)` zurück.
           * `chat`: kann entweder der neue oder der bereits existierende Chat sein
           * `didExist`: `true`, wenn der Chat schon existierte, sonst `false`.
        */
        chatVM.createNewChat(
            participants: participants,
            initialMessage: initialMessage,
            senderCharId: myCharId
        ) { chat, didExist in
            if didExist, let existingChat = chat {
                // Chat existiert bereits
                self.existingChat = existingChat
                self.showExistingChatAlert = true
            } else if let newChat = chat {
                // Neuer Chat wurde erfolgreich angelegt
                dismiss()
                onSuccess?()
            } else {
                // Fehlerfall: Chat konnte nicht erstellt werden
                print("Fehler: Chat konnte nicht erstellt werden.")
            }
        }
    }
    
    /**
     Wird aufgerufen, wenn bereits ein Chat existiert und über den Alert bestätigt wurde,
     dass man diesen öffnen möchte.
     
     - Schließt zunächst die aktuelle View (zurück zur übergeordneten View).
     - Ruft nach einer kurzen Verzögerung `chatVM.fetchMessages(for:)` auf, um Nachrichten nachzuladen.
     - Falls eine `initialMessage` vorhanden ist, wird diese bei dem existierenden Chat gesendet.
     - Abschließend wird der `onSuccess?()`-Callback getriggert.
    */
    private func navigateToChatDetail(chat: Chat) {
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Nachrichten für diesen Chat laden
            chatVM.fetchMessages(for: chat.id ?? "")
            
            // Falls der Nutzer eine Nachricht eingetippt hat, senden wir sie jetzt
            if !initialMessage.isEmpty {
                chatVM.sendMessage(to: chat, senderCharId: mySelectedCharId ?? "", text: initialMessage)
            }
            
            // Benachrichtige ggf. übergeordnete Ebene
            onSuccess?()
        }
    }
}
