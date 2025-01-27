///
//  FireUser.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// 

import FirebaseFirestore
import Foundation

/// Die `FireUser`-Struktur repräsentiert einen Benutzer der ShadowWisperJournals-App,
/// der in Firestore gespeichert ist. Sie ist `Codable`, um einfach in JSON-Daten
/// umgewandelt werden zu können, und `Identifiable`, um sie in Listen eindeutig zu identifizieren.
struct FireUser: Codable, Identifiable {
    /// Die eindeutige ID des Benutzers, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Das Registrierungsdatum des Benutzers.
    let registeredOn: Date
    
    /// Der angezeigte Name des Benutzers.
    let displayName: String
    
    /// Das Geburtsdatum des Benutzers (optional).
    let birthDate: Date?
    
    /// Das Geschlecht des Benutzers (optional).
    let gender: String?
    
    /// Der Beruf des Benutzers (optional).
    let profession: String?
}
