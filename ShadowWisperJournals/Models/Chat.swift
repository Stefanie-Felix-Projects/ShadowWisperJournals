//
//  Chat.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// Test

import FirebaseFirestore
import Foundation

struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var lastMessage: String?
    var updatedAt: Date
    var participantsSortedKey: String?
}
