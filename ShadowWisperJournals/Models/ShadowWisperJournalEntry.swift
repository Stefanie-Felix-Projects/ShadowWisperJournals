//
//  ShadowWisperJournalEntry.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// Test

import FirebaseFirestore
import Foundation

struct ShadowWisperJournalEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var content: String
    var createdAt: Date
    var userId: String
    var categoryId: String?
}
