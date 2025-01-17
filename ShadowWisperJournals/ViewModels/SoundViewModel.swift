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
import AVFoundation

@MainActor
class SoundViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [VideoItem] = []
    @Published var isLoading: Bool = false
    @Published var videoID: String = "" {
        didSet {
            guard let userID = userID else { return }
            UserDefaults.standard.set(videoID, forKey: "\(userID)_LastPlayedVideoID")
        }
    }
    
    @Published var favoriteVideos: [FavoriteVideo] = []
    @Published var ownSounds: [URL] = []
    @Published var showingDocumentPicker: Bool = false
    @Published var audioPlayer = AudioPlayer()
    @Published var loopStates: [URL: Bool] = [:]
    
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
            self.videoID = UserDefaults.standard.string(forKey: "\(Auth.auth().currentUser?.uid ?? "unknown")_LastPlayedVideoID") ?? "T2QZpy07j4s"
        } else {
            fatalError("YouTube API Key nicht in GoogleService-Info.plist gefunden")
        }
        
        authenticateUser()
        loadOwnSounds()
        loadTestSounds()
    }
    
    private func loadTestSounds() {
        let soundNames = ["Flesh Monster", "Desert Ash", "Chill Relax"]
        let extensions = ["mp3", "wav"]
        
        for soundName in soundNames {
            var soundFound = false
            for ext in extensions {
                if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                    ownSounds.append(url)
                    soundFound = true
                    break
                }
            }
            if !soundFound {
                print("Sound \(soundName) mit den Erweiterungen \(extensions.joined(separator: ", ")) nicht gefunden.")
            }
        }
    }
    
    func playOwnSound(url: URL) {
        audioPlayer.playSound(url: url, loop: loopStates[url] ?? false)
    }
    
    func pauseOwnSound(url: URL) {
        audioPlayer.pauseSound(url: url)
    }
    
    func stopOwnSound(url: URL) {
        audioPlayer.stopSound(url: url)
    }
    
    func toggleLoopOwnSound(url: URL) {
        let isLooping = audioPlayer.toggleLoop(url: url)
        loopStates[url] = isLooping
    }
    
    func authenticateUser() {
        if let user = Auth.auth().currentUser {
            self.userID = user.uid
            loadFavorites()
            loadOwnSounds()
        } else {
            Auth.auth().signInAnonymously { [weak self] authResult, error in
                if let error = error {
                    print("Fehler bei der anonymen Anmeldung: \(error)")
                    return
                }
                self?.userID = authResult?.user.uid
                self?.loadFavorites()
                self?.loadOwnSounds()
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
        guard userID != nil else { return }
        if !favoriteVideos.contains(where: { $0.id == video.idInfo.videoId }) {
            let favorite = FavoriteVideo(id: video.idInfo.videoId, title: video.snippet.title)
            favoriteVideos.append(favorite)
            saveFavoritesToFirestore()
        }
    }
    
    func removeFromFavorites(videoId: String) {
        guard userID != nil else { return }
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
    
    private func loadFavorites() {
        guard let userID = userID else { return }
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Fehler beim Laden der Favoriten: \(error)")
                return
            }
            if let data = document?.data(),
               let favoritesData = data["favoriteVideos"] as? [[String: String]] {
                DispatchQueue.main.async {
                    self?.favoriteVideos = favoritesData.compactMap { dict in
                        if let id = dict["id"], let title = dict["title"] {
                            return FavoriteVideo(id: id, title: title)
                        }
                        return nil
                    }
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
        let ownSoundsKeyForUser = "\(Auth.auth().currentUser?.uid ?? "unknown")_OwnSounds"
        if let savedSounds = UserDefaults.standard.array(forKey: ownSoundsKeyForUser) as? [String] {
            self.ownSounds = savedSounds.compactMap { URL(string: $0) }
        }
    }
    
    private func saveOwnSounds() {
        guard let userID = userID else { return }
        let ownSoundsKeyForUser = "\(userID)_OwnSounds"
        let urlStrings = ownSounds.map { $0.absoluteString }
        UserDefaults.standard.set(urlStrings, forKey: ownSoundsKeyForUser)
    }
}
