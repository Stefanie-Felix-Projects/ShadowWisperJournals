//
//  CharacterViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import Foundation
import FirebaseFirestore

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
    
    func addCharacter(name: String, attributes: [String: Int]?, backstory: String?, userId: String) {
        let now = Date()
        let newCharacter = Character(
            id: nil,
            name: name,
            attributes: attributes,
            equipment: nil,
            skills: nil,
            backstory: backstory,
            userId: userId,
            createdAt: now,
            updatedAt: now
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
}
