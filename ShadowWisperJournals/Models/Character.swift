//
//  Character.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import Foundation
import FirebaseFirestore

struct Character: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var attributes: [String: Int]?
    var equipment: [String]?
    var skills: [String]?
    var backstory: String?
    var userId: String
    var createdAt: Date
    var updatedAt: Date
}
