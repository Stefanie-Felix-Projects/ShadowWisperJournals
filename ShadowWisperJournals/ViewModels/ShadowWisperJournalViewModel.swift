//
//  ShadowWisperJournalViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// 

import FirebaseFirestore
import Foundation

/// `ShadowWisperJournalViewModel` ist eine ViewModel-Klasse zur Verwaltung von Journal-Einträgen
/// in der ShadowWisperJournals-App. Sie bietet Funktionen zum Abrufen, Hinzufügen, Aktualisieren
/// und Löschen von Journal-Einträgen und synchronisiert die Daten mit Firestore.
class ShadowWisperJournalViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// Eine Liste der Journal-Einträge, die in der UI angezeigt werden können.
    @Published var journalEntries: [ShadowWisperJournalEntry] = []
    
    // MARK: - Private Properties
    /// Instanz von Firestore für Datenbankoperationen.
    private let db = Firestore.firestore()
    
    /// Listener für Änderungen in der Firestore-Datenbank.
    private var listenerRegistration: ListenerRegistration?
    
    // MARK: - Datenabruf
    /// Ruft alle Journal-Einträge eines bestimmten Benutzers aus Firestore ab.
    /// - Parameter userId: Die ID des Benutzers, dessen Journal-Einträge geladen werden sollen.
    func fetchJournalEntries(for userId: String) {
        // Entfernt vorherige Listener, um doppelte Abfragen zu vermeiden.
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
                    // Dekodiert die Dokumente in `ShadowWisperJournalEntry`-Objekte.
                    self.journalEntries = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: ShadowWisperJournalEntry.self)
                    } ?? []
                }
            }
    }
    
    /// Entfernt den aktuellen Listener, um Ressourcen zu sparen.
    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Datenmanipulation
    /// Aktualisiert einen bestehenden Journal-Eintrag in Firestore.
    /// - Parameter entry: Der zu aktualisierende Journal-Eintrag.
    func updateJournalEntry(entry: ShadowWisperJournalEntry) {
        guard let entryId = entry.id else { return }
        
        // Aktualisiert den Eintrag in der lokalen Liste, wenn vorhanden.
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
        }
        
        // Speichert die Änderungen in Firestore.
        do {
            try db.collection("journalEntries").document(entryId).setData(from: entry)
        } catch {
            print("Fehler beim Aktualisieren des Journal-Eintrags: \(error.localizedDescription)")
        }
    }
    
    /// Fügt einen neuen Journal-Eintrag zur Firestore-Datenbank hinzu.
    /// - Parameters:
    ///   - title: Der Titel des Eintrags.
    ///   - description: Eine kurze Beschreibung des Eintrags.
    ///   - content: Der Inhalt des Eintrags.
    ///   - categoryId: Die Kategorie-ID des Eintrags (optional).
    ///   - userId: Die ID des Benutzers, der den Eintrag erstellt hat.
    func addJournalEntry(
        title: String,
        description: String,
        content: String,
        categoryId: String?,
        userId: String
    ) {
        let newEntry = ShadowWisperJournalEntry(
            id: UUID().uuidString, // Generiert eine neue eindeutige ID.
            title: title,
            description: description,
            content: content,
            createdAt: Date(),
            userId: userId,
            categoryId: categoryId
        )
        
        // Fügt den Eintrag lokal hinzu, um die UI sofort zu aktualisieren.
        journalEntries.insert(newEntry, at: 0)
        
        // Speichert den Eintrag in Firestore.
        do {
            _ = try db.collection("journalEntries").addDocument(from: newEntry)
        } catch {
            print("Fehler beim Hinzufügen des Journal-Eintrags: \(error.localizedDescription)")
        }
    }
    
    /// Löscht einen Journal-Eintrag aus der Firestore-Datenbank.
    /// - Parameter entry: Der zu löschende Journal-Eintrag.
    func deleteJournalEntry(entry: ShadowWisperJournalEntry) {
        guard let entryId = entry.id else { return }
        
        // Entfernt den Eintrag aus der lokalen Liste.
        journalEntries.removeAll { $0.id == entryId }
        
        // Löscht den Eintrag aus Firestore.
        db.collection("journalEntries").document(entryId).delete { error in
            if let error = error {
                print("Fehler beim Löschen des Journal-Eintrags: \(error.localizedDescription)")
            }
        }
    }
}
