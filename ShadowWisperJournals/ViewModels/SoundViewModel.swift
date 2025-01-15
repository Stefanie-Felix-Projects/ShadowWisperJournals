//
//  SoundViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import Foundation
import SwiftUI

@MainActor
class SoundViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [VideoItem] = []
    @Published var isLoading: Bool = false
    @Published var videoID: String = "T2QZpy07j4s"
    @Published var favoriteVideos: [String] = []
    @Published var ownSounds: [URL] = []
    @Published var showingDocumentPicker: Bool = false

    private let youTubeService: YouTubeService


    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["YouTubeAPIKey"] as? String {
            self.youTubeService = YouTubeService(apiKey: key)
        } else {
            fatalError("YouTube API Key not found in GoogleService-Info.plist")
        }

        loadFavorites()
        loadOwnSounds()
    }

    func searchOnYouTube() async {
        guard !searchQuery.isEmpty else { return }
        isLoading = true

        do {
            let results = try await youTubeService.searchVideos(keyword: searchQuery)
            searchResults = results
        } catch {
            print("Fehler bei der YouTube-Suche:", error)
        }

        isLoading = false
    }

    func addToFavorites(videoId: String) {
        if !favoriteVideos.contains(videoId) {
            favoriteVideos.append(videoId)
            saveFavorites()
        }
    }

    func addOwnSound(url: URL) {
        ownSounds.append(url)
        saveOwnSounds()
    }

    private let favoritesKey = "FavoriteVideos"
    private let ownSoundsKey = "OwnSounds"

    private func loadFavorites() {
        if let savedFavorites = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            self.favoriteVideos = savedFavorites
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(favoriteVideos, forKey: favoritesKey)
    }

    private func loadOwnSounds() {
        if let savedSounds = UserDefaults.standard.array(forKey: ownSoundsKey) as? [String] {
            self.ownSounds = savedSounds.compactMap { URL(string: $0) }
        }
    }

    private func saveOwnSounds() {
        let urlStrings = ownSounds.map { $0.absoluteString }
        UserDefaults.standard.set(urlStrings, forKey: ownSoundsKey)
    }
}
