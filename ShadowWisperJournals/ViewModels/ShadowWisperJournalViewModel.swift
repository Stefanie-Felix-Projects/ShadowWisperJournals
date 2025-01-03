//
//  ShadowWisperJournalViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//
//Test

import Foundation
import FirebaseFirestore

class ShadowWisperJournalViewModel: ObservableObject {
  
    @Published var journalEntries: [ShadowWisperJournalEntry] = []

    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    func fetchJournalEntries(for userId: String) {
        removeListener()

        listenerRegistration = db.collection("journalEntries")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Fehler beim Abrufen der Journal-Einträge: \(error.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.journalEntries = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: ShadowWisperJournalEntry.self)
                    } ?? []
                }
            }
    }

    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }

    func updateJournalEntry(entry: ShadowWisperJournalEntry) {
        guard let entryId = entry.id else { return }

        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
        }

        do {
            try db.collection("journalEntries").document(entryId).setData(from: entry)
        } catch {
            print("Fehler beim Aktualisieren des Journal-Eintrags: \(error.localizedDescription)")
        }
    }

    func addJournalEntry(
        title: String,
        description: String,
        content: String,
        categoryId: String?,
        userId: String
    ) {
        let newEntry = ShadowWisperJournalEntry(
            id: UUID().uuidString,
            title: title,
            description: description,
            content: content,
            createdAt: Date(),
            userId: userId,
            categoryId: categoryId
        )

        journalEntries.insert(newEntry, at: 0)

        do {
            _ = try db.collection("journalEntries").addDocument(from: newEntry)
        } catch {
            print("Fehler beim Hinzufügen des Journal-Eintrags: \(error.localizedDescription)")
        }
    }

    func deleteJournalEntry(entry: ShadowWisperJournalEntry) {
        guard let entryId = entry.id else { return }

        journalEntries.removeAll { $0.id == entryId }

        db.collection("journalEntries").document(entryId).delete { error in
            if let error = error {
                print("Fehler beim Löschen des Journal-Eintrags: \(error.localizedDescription)")
            }
        }
    }
}
