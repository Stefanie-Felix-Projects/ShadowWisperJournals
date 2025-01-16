//
//  SoundViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import AVFoundation // Hinzugefügt

@MainActor
class SoundViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [VideoItem] = []
    @Published var isLoading: Bool = false
    @Published var videoID: String = UserDefaults.standard.string(forKey: "LastPlayedVideoID") ?? "T2QZpy07j4s" {
        didSet {
            UserDefaults.standard.set(videoID, forKey: lastPlayedVideoKey)
        }
    }
    @Published var favoriteVideos: [FavoriteVideo] = []
    @Published var ownSounds: [URL] = []
    @Published var showingDocumentPicker: Bool = false
    @Published var audioPlayer = AudioPlayer() // Hinzugefügt
    
    private let youTubeService: YouTubeService
    private let db = Firestore.firestore()
    private var userID: String?
    private let ownSoundsKey = "OwnSounds"
    private let lastPlayedVideoKey = "LastPlayedVideoID"

    init() {
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["YouTubeAPIKey"] as? String {
            self.youTubeService = YouTubeService(apiKey: key)
        } else {
            fatalError("YouTube API Key nicht in GoogleService-Info.plist gefunden")
        }

        authenticateUser()
        loadOwnSounds()
        loadTestSounds() // Hinzugefügt
    }
    
    // Neue Methode zum Laden von Test-Sounds
    private func loadTestSounds() {
        let soundNames = ["Flesh Monster", "Desert Ash", "Chill Relax"] // Ersetze mit deinen tatsächlichen Sound-Dateinamen ohne Erweiterung
        let extensions = ["mp3", "wav"] // Liste der unterstützten Erweiterungen

        for soundName in soundNames {
            var soundFound = false
            for ext in extensions {
                if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                    ownSounds.append(url)
                    soundFound = true
                    break // Stoppe die Schleife, wenn die Datei gefunden wurde
                }
            }
            if !soundFound {
                print("Sound \(soundName) mit den Erweiterungen \(extensions.joined(separator: ", ")) nicht gefunden.")
            }
        }
    }

    func authenticateUser() {
        if let user = Auth.auth().currentUser {
            self.userID = user.uid
            loadFavorites()
        } else {
            Auth.auth().signInAnonymously { [weak self] authResult, error in
                if let error = error {
                    print("Fehler bei der anonymen Anmeldung: \(error)")
                    return
                }
                self?.userID = authResult?.user.uid
                self?.loadFavorites()
            }
        }
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

    func addToFavorites(video: VideoItem) {
        guard let userID = userID else { return }
        if !favoriteVideos.contains(where: { $0.id == video.idInfo.videoId }) {
            let favorite = FavoriteVideo(id: video.idInfo.videoId, title: video.snippet.title)
            favoriteVideos.append(favorite)
            saveFavoritesToFirestore()
        }
    }

    func removeFromFavorites(videoId: String) {
        guard let userID = userID else { return }
        if let index = favoriteVideos.firstIndex(where: { $0.id == videoId }) {
            favoriteVideos.remove(at: index)
            saveFavoritesToFirestore()
        }
    }

    func playFavoriteVideo(videoId: String) {
        videoID = videoId
    }

    func addOwnSound(url: URL) {
        ownSounds.append(url)
        saveOwnSounds()
    }
    
    // Neue Methode zum Abspielen eigener Sounds
    func playOwnSound(url: URL) {
        audioPlayer.playSound(url: url)
    }

    private func loadFavorites() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Fehler beim Laden der Favoriten: \(error)")
                return
            }
            if let data = document?.data(),
               let favoritesData = data["favoriteVideos"] as? [[String: String]] {
                self?.favoriteVideos = favoritesData.compactMap { dict in
                    if let id = dict["id"], let title = dict["title"] {
                        return FavoriteVideo(id: id, title: title)
                    }
                    return nil
                }
            }
        }
    }

    private func saveFavoritesToFirestore() {
        guard let userID = userID else { return }
        let favoritesData = favoriteVideos.map { ["id": $0.id, "title": $0.title] }
        db.collection("users").document(userID).setData([
            "favoriteVideos": favoritesData
        ], merge: true) { error in
            if let error = error {
                print("Fehler beim Speichern der Favoriten: \(error)")
            }
        }
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
