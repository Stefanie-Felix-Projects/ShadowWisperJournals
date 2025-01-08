//
//  ChatMessage.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import FirebaseFirestore
import Foundation

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var createdAt: Date
    var readBy: [String]
}
