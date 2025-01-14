//
//  QuestLogViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
// Test

import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

class QuestLogViewModel: ObservableObject {
    
    @Published var quests: [Quest] = []
    
    @Published var selectedStatus: String = "alle"
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
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
        assignedCharacterIds: [String]? = nil,
        locationString: String? = nil,
        personalNotes: String? = nil, // <- Neu
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
            completion(.failure(NSError(domain: "Quest hat keine ID", code: 0)))
            return
        }

        let storage = Storage.storage()
        let fileName = "images/quests/\(questId)/\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child(fileName)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Bild-Konvertierung fehlgeschlagen", code: 0)))
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
                    completion(.failure(NSError(domain: "Keine URL zurückgegeben", code: 0)))
                    return
                }

                self.db.collection("quests").document(questId).updateData([
                    "imageURLs": FieldValue.arrayUnion([downloadURL.absoluteString])
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}
