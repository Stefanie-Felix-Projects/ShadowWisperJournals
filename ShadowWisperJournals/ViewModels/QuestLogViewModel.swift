//
//  QuestLogViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import Foundation
import FirebaseFirestore

class QuestLogViewModel: ObservableObject {
    
    @Published var quests: [Quest] = []
    
    @Published var selectedStatus: String = "alle"
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
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
                        try? $0.data(as: Quest.self)
                    }
                }
            }
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    var filteredQuests: [Quest] {
        quests.filter { quest in
            let isInRange = quest.createdAt >= startDate && quest.createdAt <= endDate
            
            switch selectedStatus {
            case "aktiv":
                return quest.status == "aktiv" && isInRange
            case "abgeschlossen":
                return quest.status == "abgeschlossen" && isInRange
            default:
                return isInRange
            }
        }
    }
    
    // +++ NEU: assignedCharacterIds optional
    func addQuest(
        title: String,
        description: String,
        status: String,
        reward: String?,
        userId: String,
        creatorDisplayName: String? = nil,
        assignedCharacterIds: [String]? = nil  // <--- NEU
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
            assignedCharacterIds: assignedCharacterIds // <--- direkt setzen
        )
        
        do {
            _ = try db.collection("quests").addDocument(from: newQuest)
        } catch {
            print("Fehler beim Hinzufügen der Quest: \(error.localizedDescription)")
        }
    }
    
    func updateQuest(_ quest: Quest) {
        guard let questId = quest.id else { return }
        
        do {
            try db.collection("quests").document(questId).setData(from: quest)
        } catch {
            print("Fehler beim Aktualisieren der Quest: \(error.localizedDescription)")
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
}
