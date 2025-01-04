//
//  Quest.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import Foundation
import FirebaseFirestore

struct Quest: Identifiable, Codable {
    @DocumentID var id: String?    // Firestore Dokument-ID
    var title: String
    var description: String
    var status: String             // z.B. "aktiv" oder "abgeschlossen"
    var createdAt: Date
    var userId: String             // Referenz auf den User
    var reward: String?            // z.B. "500 Nuyen" oder "exp + item"
    
    // Für Filter:
    // Du kannst weitere Felder ergänzen, wenn du nach Datum etc. filtern möchtest
}
