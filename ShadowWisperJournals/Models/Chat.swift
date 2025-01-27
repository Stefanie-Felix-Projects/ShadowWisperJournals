//
//  Chat.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// 

import FirebaseFirestore
import Foundation

/// Die `Chat`-Struktur repräsentiert einen Chat zwischen zwei oder mehreren Teilnehmern
/// in der ShadowWisperJournals-App. Sie ist `Identifiable` und `Codable`, sodass sie
/// leicht in JSON umgewandelt und in einer Liste identifiziert werden kann.
struct Chat: Identifiable, Codable {
    /// Die eindeutige ID des Chats, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Eine Liste der IDs der Teilnehmer dieses Chats.
    var participants: [String]
    
    /// Die letzte Nachricht, die in diesem Chat gesendet wurde.
    var lastMessage: String?
    
    /// Das Datum und die Uhrzeit, wann der Chat zuletzt aktualisiert wurde.
    var updatedAt: Date
    
    /// Ein Schlüssel, der die Teilnehmer in einer sortierten Reihenfolge kombiniert.
    /// Kann für die effiziente Suche oder Filterung verwendet werden.
    var participantsSortedKey: String?
}
