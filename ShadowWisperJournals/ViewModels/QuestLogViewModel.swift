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

class QuestLogViewModel: ObservableObject {
    
    @Published var quests: [Quest] = []
    
    @Published var selectedStatus: String = "alle"
    @Published var startDate: Date =
    Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Date()
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchAllQuests() {
        removeListener()
        
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
                            
                            // Falls imageURLs nil ist, initialisieren
                            if quest.imageURLs == nil {
                                quest.imageURLs = []
                            }
                            
                            print("QUEST GELADEN: \(quest)") // Debug-Log
                            return quest
                        } catch {
                            print("Fehler beim Dekodieren einer Quest: \(error.localizedDescription)")
                            return nil
                        }
                    }
                }
            }
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    func addQuest(
        title: String,
        description: String,
        status: String,
        reward: String?,
        userId: String,
        creatorDisplayName: String? = nil,
        assignedCharacterIds: [String]? = nil
    ) {
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
            imageURLs: []
        )
        
        do {
            _ = try db.collection("quests").addDocument(from: newQuest)
        } catch {
            print("Fehler beim Hinzufügen der Quest: \(error.localizedDescription)")
        }
    }
    
    func updateQuest(_ quest: Quest) {
        guard let questId = quest.id else {
            print("UPDATE ERROR: Quest hat keine ID")
            return
        }

        print("UPDATE BEGINN: \(questId) mit neuen Daten: \(quest)")

        do {

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

            try db.collection("quests").document(questId).setData(updateData, merge: true)
            print("UPDATE ERFOLGREICH: Quest \(questId) wurde aktualisiert")
        } catch {
            print("UPDATE ERROR: \(error.localizedDescription)")
        }
    }
    func deleteQuest(_ quest: Quest) {
        guard let questId = quest.id else { return }
        db.collection("quests").document(questId).delete { error in
            if let error = error {
                print("Fehler beim Löschen der Quest: \(error.localizedDescription)")
            }
        }
    }
    
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
    
    func uploadImage(
        _ image: UIImage,
        for quest: Quest,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let questId = quest.id else {
            print("UPLOAD ERROR: Quest hat keine ID")
            completion(.failure(NSError(domain: "Quest hat keine ID", code: 0)))
            return
        }

        let storage = Storage.storage()
        let fileName = "images/quests/\(questId)/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child(fileName)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("UPLOAD ERROR: Bild konnte nicht in JPEG umgewandelt werden")
            completion(.failure(NSError(domain: "Bild-Konvertierung fehlgeschlagen", code: 0)))
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        print("BEGINNE UPLOAD: \(fileName)")

        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("UPLOAD ERROR: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("DOWNLOAD-URL ERROR: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url else {
                    print("DOWNLOAD-URL ERROR: Keine URL zurückgegeben")
                    completion(.failure(NSError(domain: "Keine URL zurückgegeben", code: 0)))
                    return
                }

                print("DOWNLOAD-URL ERFOLGREICH: \(downloadURL.absoluteString)")

                
                self.db.collection("quests").document(questId).updateData([
                    "imageURLs": FieldValue.arrayUnion([downloadURL.absoluteString])
                ]) { error in
                    if let error = error {
                        print("FEHLER BEIM UPDATEN DER IMAGE URLS: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }

                    print("IMAGE URL ERFOLGREICH IN FIRESTORE GESPEICHERT: \(downloadURL.absoluteString)")
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}
