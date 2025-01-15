//
//  YouTubeModels.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import Foundation

struct YouTubeSearchResult: Decodable {
    let items: [VideoItem]
}

struct VideoItem: Decodable, Identifiable {
    var id: String { idInfo.videoId }
    let idInfo: IDInfo
    let snippet: Snippet
    
    enum CodingKeys: String, CodingKey {
        case idInfo = "id"
        case snippet
    }
}

struct IDInfo: Decodable {
    let videoId: String
}

struct Snippet: Decodable {
    let title: String
    let description: String
    let thumbnails: Thumbnails
}

struct Thumbnails: Decodable {
    let defaultThumbnail: Thumbnail
    
    enum CodingKeys: String, CodingKey {
        case defaultThumbnail = "default"
    }
}

struct Thumbnail: Decodable {
    let url: String
}
