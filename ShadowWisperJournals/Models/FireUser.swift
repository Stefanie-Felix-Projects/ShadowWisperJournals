///
//  FireUser.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import Foundation
import FirebaseFirestore

struct FireUser: Codable, Identifiable {
    @DocumentID var id: String?
    let registeredOn: Date
    let displayName: String
    let birthDate: Date?
    let gender: String?
    let profession: String?
}
