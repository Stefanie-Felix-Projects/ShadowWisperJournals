//
//  ShadowWisperJournalEntry.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// 

import FirebaseFirestore
import Foundation

/// Die `ShadowWisperJournalEntry`-Struktur repräsentiert einen Eintrag in einem digitalen Journal
/// der ShadowWisperJournals-App. Sie ist `Identifiable` und `Codable`, um leicht in JSON-Daten
/// umgewandelt und in Listen identifiziert werden zu können.
struct ShadowWisperJournalEntry: Identifiable, Codable {
    /// Die eindeutige ID des Journaleintrags, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Der Titel des Journaleintrags.
    var title: String
    
    /// Eine kurze Beschreibung des Journaleintrags.
    var description: String
    
    /// Der vollständige Inhalt des Journaleintrags.
    var content: String
    
    /// Das Datum und die Uhrzeit, wann der Journaleintrag erstellt wurde.
    var createdAt: Date
    
    /// Die ID des Benutzers, der den Journaleintrag erstellt hat.
    var userId: String
    
    /// Die ID der Kategorie, zu der der Journaleintrag gehört (optional).
    var categoryId: String?
}
