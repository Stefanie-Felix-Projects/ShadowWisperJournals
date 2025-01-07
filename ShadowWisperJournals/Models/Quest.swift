//
//  Quest.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import Foundation
import FirebaseFirestore

struct Quest: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var status: String
    var createdAt: Date
    var userId: String
    var reward: String?
    var creatorDisplayName: String?
    var assignedCharacterIds: [String]?
}
