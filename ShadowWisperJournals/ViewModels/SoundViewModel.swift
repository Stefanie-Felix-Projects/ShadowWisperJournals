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

/// `SoundViewModel` ist eine ViewModel-Klasse zur Verwaltung von Sounds, YouTube-Suchen
/// und Favoriten in der ShadowWisperJournals-App.
///
/// Hauptfunktionen:
/// - Abspielen, Pausieren, Stoppen und Loopen von eigenen Sounds.
/// - Integration mit YouTube-Suchen und Verwaltung von Favoriten.
/// - Speicherung und Abruf von Benutzerdaten in Firebase und UserDefaults.
@MainActor
class SoundViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// Der aktuelle Suchbegriff für YouTube-Suchen.
    @Published var searchQuery: String = ""
    
    /// Die Ergebnisse der YouTube-Suche.
    @Published var searchResults: [VideoItem] = []
    
    /// Gibt an, ob die YouTube-Suche gerade läuft.
    @Published var isLoading: Bool = false
    
    /// Die ID des aktuell abgespielten YouTube-Videos.
    @Published var videoID: String = "" {
        didSet {
            guard let userID = userID else { return }
            UserDefaults.standard.set(videoID, forKey: "\(userID)_LastPlayedVideoID")
        }
    }
    
    /// Die Liste der Favoriten-Videos des Benutzers.
    @Published var favoriteVideos: [FavoriteVideo] = []
    
    /// Eine Liste der hochgeladenen Sounds des Benutzers.
    @Published var ownSounds: [URL] = []
    
    /// Gibt an, ob der Dokumenten-Picker angezeigt wird.
    @Published var showingDocumentPicker: Bool = false
    
    /// Die Instanz des AudioPlayers zur Soundsteuerung.
    @Published var audioPlayer = AudioPlayer()
    
    /// Der Loop-Status für jeden Sound (an/aus).
    @Published var loopStates: [URL: Bool] = [:]
    
    // MARK: - Private Properties
    /// Instanz des YouTube-Service für API-Aufrufe.
    private let youTubeService: YouTubeService
    
    /// Firestore-Instanz für Datenbankoperationen.
    private let db = Firestore.firestore()
    
    /// Die Benutzer-ID des aktuell authentifizierten Benutzers.
    private var userID: String?
    
    /// Schlüssel für die Speicherung eigener Sounds in `UserDefaults`.
    private let ownSoundsKey = "OwnSounds"
    
    /// Schlüssel für das zuletzt abgespielte Video.
    private let lastPlayedVideoKey = "LastPlayedVideoID"
    
    // MARK: - Initializer
    /// Initialisiert das `SoundViewModel` und lädt die API-Schlüssel und Benutzerdaten.
    init() {
        // Lädt den YouTube-API-Schlüssel aus der `GoogleService-Info.plist`.
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
    
    // MARK: - Test-Sounds
    /// Lädt eine Liste von Test-Sounds aus dem Bundle, wenn vorhanden.
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
    
    // MARK: - Sound-Steuerung
    /// Spielt einen eigenen Sound ab.
    /// - Parameter url: Die URL des Sounds.
    func playOwnSound(url: URL) {
        audioPlayer.playSound(url: url, loop: loopStates[url] ?? false)
    }
    
    /// Pausiert einen eigenen Sound.
    /// - Parameter url: Die URL des Sounds.
    func pauseOwnSound(url: URL) {
        audioPlayer.pauseSound(url: url)
    }
    
    /// Stoppt einen eigenen Sound.
    /// - Parameter url: Die URL des Sounds.
    func stopOwnSound(url: URL) {
        audioPlayer.stopSound(url: url)
    }
    
    /// Schaltet den Loop-Modus für einen eigenen Sound um.
    /// - Parameter url: Die URL des Sounds.
    func toggleLoopOwnSound(url: URL) {
        let isLooping = audioPlayer.toggleLoop(url: url)
        loopStates[url] = isLooping
    }
    
    // MARK: - YouTube-Suche
    /// Führt eine Suche auf YouTube mit dem aktuellen Suchbegriff durch.
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
    
    // MARK: - Favoriten-Verwaltung
    /// Fügt ein Video den Favoriten hinzu.
    /// - Parameter video: Das hinzuzufügende Video.
    func addToFavorites(video: VideoItem) {
        guard userID != nil else { return }
        if !favoriteVideos.contains(where: { $0.id == video.idInfo.videoId }) {
            let favorite = FavoriteVideo(id: video.idInfo.videoId, title: video.snippet.title)
            favoriteVideos.append(favorite)
            saveFavoritesToFirestore()
        }
    }
    
    /// Entfernt ein Video aus den Favoriten.
    /// - Parameter videoId: Die ID des Videos.
    func removeFromFavorites(videoId: String) {
        guard userID != nil else { return }
        if let index = favoriteVideos.firstIndex(where: { $0.id == videoId }) {
            favoriteVideos.remove(at: index)
            saveFavoritesToFirestore()
        }
    }
    
    /// Spielt ein Favoriten-Video ab.
    /// - Parameter videoId: Die ID des Videos.
    func playFavoriteVideo(videoId: String) {
        videoID = videoId
    }
    
    // MARK: - Eigene Sounds
    /// Fügt einen neuen eigenen Sound hinzu.
    /// - Parameter url: Die URL des Sounds.
    func addOwnSound(url: URL) {
        ownSounds.append(url)
        saveOwnSounds()
    }
    
    /// Lädt eigene Sounds aus `UserDefaults`.
    private func loadOwnSounds() {
        let ownSoundsKeyForUser = "\(Auth.auth().currentUser?.uid ?? "unknown")_OwnSounds"
        if let savedSounds = UserDefaults.standard.array(forKey: ownSoundsKeyForUser) as? [String] {
            self.ownSounds = savedSounds.compactMap { URL(string: $0) }
        }
    }
    
    /// Speichert eigene Sounds in `UserDefaults`.
    private func saveOwnSounds() {
        guard let userID = userID else { return }
        let ownSoundsKeyForUser = "\(userID)_OwnSounds"
        let urlStrings = ownSounds.map { $0.absoluteString }
        UserDefaults.standard.set(urlStrings, forKey: ownSoundsKeyForUser)
    }
    
    // MARK: - Favoriten in Firestore
    /// Lädt die Favoriten des Benutzers aus Firestore.
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
    
    /// Speichert die Favoriten des Benutzers in Firestore.
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
    
    // MARK: - Benutzer-Authentifizierung
    /// Authentifiziert den Benutzer (anonym, falls kein Benutzer angemeldet ist).
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
}
