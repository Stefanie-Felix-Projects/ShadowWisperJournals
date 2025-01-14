//
//  Character.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// Test

import FirebaseFirestore
import Foundation

struct Character: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var attributes: [String: Int]?
    var skillPoints: [String: Int]?
    var equipment: [String]?
    var backstory: String?
    var userId: String
    var createdAt: Date
    var updatedAt: Date

    var streetName: String?
    var metaType: String?
    var specialization: String?
    var magicOrResonance: String?
    var gender: String?
    var height: Int?
    var weight: Int?
    var age: Int?
    var reputation: Int?
    var wantedLevel: Int?
    var karma: Int?
    var essence: Double?
    var imageURLs: [String]?
    var profileImageURL: String?
}
