//
//  Character.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import FirebaseFirestore
import Foundation

/// Die `Character`-Struktur repräsentiert einen Charakter in der ShadowWisperJournals-App.
/// Diese Struktur ist `Identifiable` und `Codable`, was bedeutet, dass sie leicht
/// in JSON-Daten umgewandelt und in einer Liste identifiziert werden kann.
struct Character: Identifiable, Codable {
    /// Die eindeutige ID des Charakters, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Der Name des Charakters.
    var name: String
    
    /// Attribute des Charakters (z. B. Stärke, Geschicklichkeit), gespeichert als Schlüssel-Wert-Paare.
    var attributes: [String: Int]?
    
    /// Fertigkeitspunkte des Charakters, ebenfalls als Schlüssel-Wert-Paare gespeichert.
    var skillPoints: [String: Int]?
    
    /// Liste der Ausrüstungsgegenstände des Charakters.
    var equipment: [String]?
    
    /// Hintergrundgeschichte des Charakters.
    var backstory: String?
    
    /// Die ID des Benutzers, dem der Charakter gehört.
    var userId: String
    
    /// Das Erstellungsdatum des Charakters.
    var createdAt: Date
    
    /// Das Datum der letzten Aktualisierung des Charakters.
    var updatedAt: Date
    
    // MARK: - Zusätzliche Charaktereigenschaften
    /// Der Straßenname (Alias) des Charakters.
    var streetName: String?
    
    /// Der Metatyp des Charakters (z. B. Mensch, Elf, Zwerg).
    var metaType: String?
    
    /// Die Spezialisierung des Charakters (z. B. Decker, Rigger).
    var specialization: String?
    
    /// Die magischen oder Resonanzfähigkeiten des Charakters.
    var magicOrResonance: String?
    
    /// Das Geschlecht des Charakters.
    var gender: String?
    
    /// Die Körpergröße des Charakters in Zentimetern.
    var height: Int?
    
    /// Das Gewicht des Charakters in Kilogramm.
    var weight: Int?
    
    /// Das Alter des Charakters.
    var age: Int?
    
    /// Der Ruf des Charakters (positiv oder negativ).
    var reputation: Int?
    
    /// Der Fahndungslevel des Charakters.
    var wantedLevel: Int?
    
    /// Karma des Charakters (Erfahrungspunkte für Fortschritt).
    var karma: Int?
    
    /// Die Essenz des Charakters (ein Maß für Menschlichkeit).
    var essence: Double?
    
    /// URLs von zusätzlichen Bildern, die mit dem Charakter verknüpft sind.
    var imageURLs: [String]?
    
    /// URL des Profilbilds des Charakters.
    var profileImageURL: String?
}
