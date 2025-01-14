//
//  CharacterViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit

class CharacterViewModel: ObservableObject {
    @Published var characters: [Character] = []
    
    let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func fetchAllCharacters() {
        removeListener()
        
        listenerRegistration = db.collection("characters")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Abrufen aller Charaktere: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    self.characters = documents.compactMap {
                        try? $0.data(as: Character.self)
                    }
                }
            }
    }
    
    func fetchCharacters(for userId: String) {
        removeListener()
        
        listenerRegistration = db.collection("characters")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Fehler beim Abrufen der Charaktere: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                DispatchQueue.main.async {
                    self.characters = documents.compactMap {
                        try? $0.data(as: Character.self)
                    }
                }
            }
    }
    
    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    func addCharacter(
        name: String,
        attributes: [String: Int]?,
        skillPoints: [String: Int]?,
        backstory: String?,
        userId: String,
        streetName: String? = nil,
        metaType: String? = nil,
        specialization: String? = nil,
        magicOrResonance: String? = nil,
        gender: String? = nil,
        height: Int? = nil,
        weight: Int? = nil,
        age: Int? = nil,
        reputation: Int? = nil,
        wantedLevel: Int? = nil,
        karma: Int? = nil,
        essence: Double? = nil
    ) {
        let now = Date()
        let newCharacter = Character(
            id: nil,
            name: name,
            attributes: attributes,
            skillPoints: skillPoints,
            equipment: nil,
            backstory: backstory,
            userId: userId,
            createdAt: now,
            updatedAt: now,
            streetName: streetName,
            metaType: metaType,
            specialization: specialization,
            magicOrResonance: magicOrResonance,
            gender: gender,
            height: height,
            weight: weight,
            age: age,
            reputation: reputation,
            wantedLevel: wantedLevel,
            karma: karma,
            essence: essence,
            imageURLs: [],
            profileImageURL: nil
        )
        
        do {
            _ = try db.collection("characters").addDocument(from: newCharacter)
        } catch {
            print("Fehler beim Hinzufügen des Charakters: \(error.localizedDescription)")
        }
    }
    
    func updateCharacter(_ character: Character) {
        guard let characterId = character.id else { return }
        
        var updatedCharacter = character
        updatedCharacter.updatedAt = Date()
        
        do {
            try db.collection("characters").document(characterId).setData(from: updatedCharacter)
        } catch {
            print("Fehler beim Aktualisieren des Charakters: \(error.localizedDescription)")
        }
    }
    
    func deleteCharacter(_ character: Character) {
        guard let characterId = character.id else { return }
        
        db.collection("characters").document(characterId).delete { error in
            if let error = error {
                print("Fehler beim Löschen des Charakters: \(error.localizedDescription)")
            }
        }
    }

    func uploadImage(
        _ image: UIImage,
        for character: Character,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let charId = character.id else {
            completion(.failure(NSError(domain: "Character hat keine ID", code: 0)))
            return
        }

        let storage = Storage.storage()
        let fileName = "images/characters/\(charId)/\(UUID().uuidString).jpg"
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

                self.db.collection("characters").document(charId).updateData([
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

    func uploadProfileImage(
        _ image: UIImage,
        for character: Character,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let charId = character.id else {
            completion(.failure(NSError(domain: "Character hat keine ID", code: 0)))
            return
        }

        let storage = Storage.storage()
        let fileName = "images/characters/\(charId)/profile.jpg"
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

                self.db.collection("characters").document(charId).updateData([
                    "profileImageURL": downloadURL.absoluteString
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
