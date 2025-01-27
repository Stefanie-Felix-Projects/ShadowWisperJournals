//
//  YouTubeModels.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import Foundation

/// Die `YouTubeSearchResult`-Struktur repräsentiert das Ergebnis einer YouTube-Suche.
/// Sie enthält eine Liste von Videos als `VideoItem`.
struct YouTubeSearchResult: Decodable {
    /// Eine Liste der gefundenen Videos.
    let items: [VideoItem]
}

/// Die `VideoItem`-Struktur repräsentiert ein einzelnes YouTube-Video.
/// Sie ist `Decodable` und `Identifiable`, wobei die `id` die Video-ID ist.
struct VideoItem: Decodable, Identifiable {
    /// Die eindeutige ID des Videos, abgeleitet aus `idInfo`.
    var id: String { idInfo.videoId }
    
    /// Informationen zur Video-ID.
    let idInfo: IDInfo
    
    /// Metadaten des Videos, wie Titel und Beschreibung.
    let snippet: Snippet
    
    /// Die Zuordnung der JSON-Codierungsschlüssel zu den Eigenschaften.
    enum CodingKeys: String, CodingKey {
        case idInfo = "id"
        case snippet
    }
}

/// Die `IDInfo`-Struktur enthält die Video-ID eines YouTube-Videos.
struct IDInfo: Decodable {
    /// Die eindeutige Video-ID.
    let videoId: String
}

/// Die `Snippet`-Struktur enthält Metadaten zu einem Video, wie Titel, Beschreibung und Thumbnails.
struct Snippet: Decodable {
    /// Der Titel des Videos.
    let title: String
    
    /// Die Beschreibung des Videos.
    let description: String
    
    /// Die Thumbnails des Videos.
    let thumbnails: Thumbnails
}

/// Die `Thumbnails`-Struktur enthält verschiedene Thumbnail-Informationen.
struct Thumbnails: Decodable {
    /// Das Standard-Thumbnail des Videos.
    let defaultThumbnail: Thumbnail
    
    /// Die Zuordnung der JSON-Codierungsschlüssel zu den Eigenschaften.
    enum CodingKeys: String, CodingKey {
        case defaultThumbnail = "default"
    }
}

/// Die `Thumbnail`-Struktur repräsentiert ein einzelnes Thumbnail eines Videos.
struct Thumbnail: Decodable {
    /// Die URL des Thumbnails.
    let url: String
}
