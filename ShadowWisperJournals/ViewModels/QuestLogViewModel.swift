//
//  QuestLogViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
// 

import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

/// `QuestLogViewModel` ist eine ViewModel-Klasse zur Verwaltung und Bearbeitung von Quests
/// in der ShadowWisperJournals-App. Sie nutzt Firebase Firestore und Firebase Storage,
/// um Datenbanken und Bilder effizient zu verwalten.
///
/// Funktionen umfassen:
/// - Abrufen, Hinzufügen, Aktualisieren und Löschen von Quests
/// - Zuweisen von Charakteren zu Quests
/// - Hochladen von Bildern zu Firebase Storage
class QuestLogViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// Eine Liste aller Quests, die in der UI angezeigt werden.
    @Published var quests: [Quest] = []
    
    /// Der aktuell ausgewählte Statusfilter (z. B. "offen", "abgeschlossen", "alle").
    @Published var selectedStatus: String = "alle"
    
    /// Das Startdatum des Filterzeitraums.
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    
    /// Das Enddatum des Filterzeitraums.
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    // MARK: - Private Properties
    /// Firestore-Instanz für Datenbankoperationen.
    private let db = Firestore.firestore()
    
    /// Listener für Datenänderungen in der Firestore-Datenbank.
    private var listener: ListenerRegistration?
    
    // MARK: - Datenabruf
    /// Ruft alle Quests aus der Firestore-Datenbank ab und aktualisiert die `quests`-Liste.
    /// - Die Daten werden nach dem Erstellungsdatum sortiert (neueste zuerst).
    func fetchAllQuests() {
        listener = db.collection("quests")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Abrufen der Quests: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    self.quests = documents.compactMap {
                        do {
                            var quest = try $0.data(as: Quest.self)
                            // Sicherstellen, dass imageURLs nicht nil ist
                            if quest.imageURLs == nil {
                                quest.imageURLs = []
                            }
                            return quest
                        } catch {
                            print("Fehler beim Dekodieren einer Quest: \(error.localizedDescription)")
                            return nil
                        }
                    }
                    print("DEBUG: Alle Quests aus Firestore neu geladen, Count = \(self.quests.count)")
                }
            }
    }
    
    /// Entfernt den Firestore-Listener, um Ressourcen zu sparen.
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Datenmanipulation
    /// Fügt eine neue Quest zur Firestore-Datenbank hinzu und speichert sie lokal.
    ///
    /// - Parameters:
    ///   - title: Der Titel der Quest.
    ///   - description: Die Beschreibung der Quest.
    ///   - status: Der Status der Quest (z. B. "offen", "abgeschlossen").
    ///   - reward: Die Belohnung der Quest (optional).
    ///   - userId: Die ID des Benutzers, der die Quest erstellt hat.
    ///   - creatorDisplayName: Der Anzeigename des Erstellers (optional).
    ///   - assignedCharacterIds: IDs der Charaktere, die der Quest zugewiesen sind (optional).
    ///   - locationString: Der Ort der Quest (optional).
    ///   - personalNotes: Persönliche Notizen zur Quest (optional).
    ///   - completion: Ein Callback, das entweder die ID der neuen Quest oder einen Fehler zurückgibt.
    func addQuest(
        title: String,
        description: String,
        status: String,
        reward: String?,
        userId: String,
        creatorDisplayName: String? = nil,
        assignedCharacterIds: [String]? = nil,
        locationString: String? = nil,
        personalNotes: String? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        print("DEBUG: addQuest() aufgerufen mit userId = \(userId)")
        
        let newQuest = Quest(
            id: nil,
            title: title,
            description: description,
            status: status,
            createdAt: Date(),
            userId: userId,
            reward: reward,
            creatorDisplayName: creatorDisplayName,
            assignedCharacterIds: assignedCharacterIds,
            imageURLs: [],
            locationString: locationString,
            personalNotes: personalNotes
        )
        
        do {
            let ref = try db.collection("quests").addDocument(from: newQuest)
            
            var localQuest = newQuest
            localQuest.id = ref.documentID
            self.quests.insert(localQuest, at: 0)
            
            print("DEBUG: Neue Quest lokal eingefügt -> id = \(localQuest.id ?? "nil"), userId = \(localQuest.userId)")
            
            self.objectWillChange.send()
            
            completion(.success(ref.documentID))
            
        } catch {
            print("Fehler beim Hinzufügen der Quest: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    /// Aktualisiert eine bestehende Quest in der Firestore-Datenbank.
    /// - Parameter quest: Die zu aktualisierende Quest.
    func updateQuest(_ quest: Quest) {
        guard let questId = quest.id else {
            print("UPDATE ERROR: Quest hat keine ID")
            return
        }
        
        var updateData: [String: Any] = [
            "title": quest.title,
            "description": quest.description,
            "status": quest.status,
            "createdAt": quest.createdAt,
            "userId": quest.userId
        ]
        
        if let reward = quest.reward {
            updateData["reward"] = reward
        }
        if let creatorDisplayName = quest.creatorDisplayName {
            updateData["creatorDisplayName"] = creatorDisplayName
        }
        if let assignedCharacterIds = quest.assignedCharacterIds {
            updateData["assignedCharacterIds"] = assignedCharacterIds
        }
        if let imageURLs = quest.imageURLs {
            updateData["imageURLs"] = imageURLs
        }
        if let locationStr = quest.locationString {
            updateData["locationString"] = locationStr
        }
        if let notes = quest.personalNotes {
            updateData["personalNotes"] = notes
        } else {
            updateData["personalNotes"] = FieldValue.delete()
        }
        
        db.collection("quests").document(questId).setData(updateData, merge: true) { error in
            if let error = error {
                print("UPDATE ERROR: \(error.localizedDescription)")
            } else {
                print("DEBUG: Quest erfolgreich aktualisiert.")
            }
        }
    }
    
    /// Löscht eine Quest aus der Firestore-Datenbank.
    /// - Parameter quest: Die zu löschende Quest.
    func deleteQuest(_ quest: Quest) {
        guard let questId = quest.id else { return }
        db.collection("quests").document(questId).delete { error in
            if let error = error {
                print("Fehler beim Löschen der Quest: \(error.localizedDescription)")
            } else {
                print("DEBUG: Quest erfolgreich gelöscht.")
            }
        }
    }
    
    /// Weist einer Quest neue Charaktere zu.
    /// - Parameters:
    ///   - quest: Die Quest, die aktualisiert werden soll.
    ///   - characterIds: Eine Liste von Charakter-IDs, die der Quest zugewiesen werden sollen.
    func assignCharactersToQuest(quest: Quest, characterIds: [String]) {
        guard let questId = quest.id else { return }
        
        var newAssigned = quest.assignedCharacterIds ?? []
        
        for cid in characterIds {
            if !newAssigned.contains(cid) {
                newAssigned.append(cid)
            }
        }
        
        var updatedQuest = quest
        updatedQuest.assignedCharacterIds = newAssigned
        
        do {
            try db.collection("quests")
                .document(questId)
                .setData(from: updatedQuest, merge: true)
        } catch {
            print("Fehler beim Zuweisen der Charaktere: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Bildverwaltung
    /// Lädt ein Bild für eine Quest in Firebase Storage hoch und gibt die Bild-URL zurück.
    /// - Parameters:
    ///   - image: Das Bild, das hochgeladen werden soll.
    ///   - quest: Die Quest, zu der das Bild gehört.
    ///   - completion: Ein Callback, das entweder die Bild-URL oder einen Fehler zurückgibt.
    func uploadImage(
        _ image: UIImage,
        for quest: Quest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let questId = quest.id else {
            completion(.failure(NSError(domain: "Quest hat keine ID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Die Quest hat keine ID."])))
            return
        }
        
        let storage = Storage.storage()
        let fileName = "images/quests/\(questId)/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Bild-Konvertierung fehlgeschlagen", code: 0, userInfo: [NSLocalizedDescriptionKey: "Das Bild konnte nicht konvertiert werden."])))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "Keine URL zurückgegeben", code: 0, userInfo: [NSLocalizedDescriptionKey: "Die Download-URL konnte nicht abgerufen werden."])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
}
