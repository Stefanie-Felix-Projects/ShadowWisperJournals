//
//  Quest.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
// 

import FirebaseFirestore
import Foundation

/// Die `Quest`-Struktur repräsentiert eine Aufgabe oder Mission in der ShadowWisperJournals-App.
/// Sie ist `Identifiable` und `Codable`, um leicht in JSON-Daten umgewandelt und in Listen identifiziert werden zu können.
struct Quest: Identifiable, Codable {
    /// Die eindeutige ID der Quest, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Der Titel der Quest.
    var title: String
    
    /// Eine detaillierte Beschreibung der Quest.
    var description: String
    
    /// Der aktuelle Status der Quest (z. B. "Offen", "In Bearbeitung", "Abgeschlossen").
    var status: String
    
    /// Das Datum und die Uhrzeit, wann die Quest erstellt wurde.
    var createdAt: Date
    
    /// Die ID des Benutzers, der die Quest erstellt hat.
    var userId: String
    
    /// Die Belohnung für das Abschließen der Quest (optional).
    var reward: String?
    
    /// Der Anzeigename des Erstellers der Quest (optional).
    var creatorDisplayName: String?
    
    /// Eine Liste von IDs der Charaktere, die der Quest zugewiesen wurden (optional).
    var assignedCharacterIds: [String]?
    
    /// Eine Liste von URLs zu Bildern, die mit der Quest verknüpft sind (optional).
    var imageURLs: [String]?
    
    /// Ein Textfeld für den Ort, an dem die Quest stattfindet (optional).
    var locationString: String?
    
    /// Persönliche Notizen des Benutzers zur Quest (optional).
    var personalNotes: String?
}
