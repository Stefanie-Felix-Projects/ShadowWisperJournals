//
//  FavoriteVideo.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import Foundation

/// Die `FavoriteVideo`-Struktur repräsentiert ein favorisiertes Video.
/// Sie ist `Identifiable`, wodurch jede Instanz über eine eindeutige ID identifiziert werden kann.
struct FavoriteVideo: Identifiable {
    /// Die eindeutige ID des Videos.
    let id: String
    
    /// Der Titel des Videos.
    let title: String
}
