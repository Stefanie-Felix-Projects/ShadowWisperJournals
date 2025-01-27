//
//  ChatMessage.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// 

import FirebaseFirestore
import Foundation

/// Die `ChatMessage`-Struktur repräsentiert eine Nachricht in einem Chat
/// der ShadowWisperJournals-App. Sie ist `Identifiable` und `Codable`,
/// um leicht identifiziert und in JSON umgewandelt werden zu können.
struct ChatMessage: Identifiable, Codable {
    /// Die eindeutige ID der Nachricht, die von Firestore generiert wird.
    @DocumentID var id: String?
    
    /// Die ID des Absenders der Nachricht.
    var senderId: String
    
    /// Der Textinhalt der Nachricht.
    var text: String
    
    /// Das Erstellungsdatum und die Uhrzeit der Nachricht.
    var createdAt: Date
    
    /// Eine Liste der IDs der Benutzer, die die Nachricht gelesen haben.
    var readBy: [String]
}
