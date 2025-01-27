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

/// `CharacterViewModel` ist eine ViewModel-Klasse, die die Logik für die Verwaltung und Verarbeitung
/// von Charakterdaten in der ShadowWisperJournals-App bereitstellt.
/// Sie implementiert Firebase Firestore und Storage für Datenbankoperationen und Bildverwaltung.
class CharacterViewModel: ObservableObject {
    /// Eine Liste von Charakteren, die als Observable bereitgestellt wird, um Änderungen in der UI zu reflektieren.
    @Published var characters: [Character] = []
    
    /// Instanz von Firestore für die Datenbankinteraktion.
    let db = Firestore.firestore()
    
    /// Listener-Registrierung für Firestore-Datenabfragen.
    private var listenerRegistration: ListenerRegistration?
    
    // MARK: - Datenabruf
    /// Ruft alle Charaktere aus der Firestore-Datenbank ab, sortiert nach Erstellungsdatum in absteigender Reihenfolge.
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
    
    /// Ruft Charaktere ab, die zu einem bestimmten Benutzer gehören.
    /// - Parameter userId: Die ID des Benutzers, für den Charaktere abgerufen werden sollen.
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
    
    /// Entfernt den aktuellen Firestore-Listener.
    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Datenmanipulation
    /// Fügt einen neuen Charakter in die Firestore-Datenbank ein.
    /// - Parameter name: Der Name des Charakters.
    /// - Weitere Parameter: Eigenschaften des Charakters wie Attribute, Skill-Punkte und Hintergrundgeschichte.
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
    
    /// Aktualisiert die Daten eines bestehenden Charakters.
    /// - Parameter character: Der zu aktualisierende Charakter.
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
    
    /// Löscht einen Charakter aus der Firestore-Datenbank.
    /// - Parameter character: Der zu löschende Charakter.
    func deleteCharacter(_ character: Character) {
        guard let characterId = character.id else { return }
        
        db.collection("characters").document(characterId).delete { error in
            if let error = error {
                print("Fehler beim Löschen des Charakters: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Bildverwaltung
    /// Lädt ein Bild für einen Charakter hoch und speichert die Bild-URL in der Datenbank.
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
    
    /// Lädt ein Profilbild für einen Charakter hoch und speichert die Bild-URL in der Datenbank.
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
