//
//  AudioPlayer.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI
import AVFoundation

/// Die `AudioPlayer`-Klasse ermöglicht das Abspielen, Pausieren, Stoppen und Loopen von Audio-Dateien.
/// Sie ist `ObservableObject`, damit sie in SwiftUI-Views verwendet werden kann, und verwendet `AVAudioPlayer`
/// für die Audioverarbeitung.
class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    /// Ein Dictionary, das URLs von Audiodateien mit ihren zugehörigen `AVAudioPlayer`-Instanzen speichert.
    @Published var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    /// Spielt eine Audiodatei ab.
    /// - Parameters:
    ///   - url: Die URL der Audiodatei, die abgespielt werden soll.
    ///   - loop: Gibt an, ob die Datei in einer Endlosschleife abgespielt werden soll (Standard: `false`).
    func playSound(url: URL, loop: Bool = false) {
        do {
            // Stoppt einen existierenden Player für die gleiche Datei, falls vorhanden.
            if let existingPlayer = audioPlayers[url], existingPlayer.isPlaying {
                existingPlayer.stop()
            }
            // Erstellt einen neuen Player und startet die Wiedergabe.
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.numberOfLoops = loop ? -1 : 0
            player.play()
            audioPlayers[url] = player
        } catch {
            // Gibt eine Fehlermeldung aus, wenn die Datei nicht abgespielt werden kann.
            print("Fehler beim Abspielen des Sounds: \(error)")
        }
    }
    
    /// Pausiert die Wiedergabe einer Audiodatei.
    /// - Parameter url: Die URL der Audiodatei, die pausiert werden soll.
    func pauseSound(url: URL) {
        if let player = audioPlayers[url], player.isPlaying {
            player.pause()
        }
    }
    
    /// Stoppt die Wiedergabe einer Audiodatei und entfernt den Player aus dem Dictionary.
    /// - Parameter url: Die URL der Audiodatei, die gestoppt werden soll.
    func stopSound(url: URL) {
        if let player = audioPlayers[url] {
            player.stop()
            audioPlayers.removeValue(forKey: url)
        }
    }
    
    /// Schaltet den Loop-Modus für eine Audiodatei um.
    /// - Parameter url: Die URL der Audiodatei, deren Loop-Modus umgeschaltet werden soll.
    /// - Returns: `true`, wenn der Loop-Modus aktiviert ist, ansonsten `false`.
    func toggleLoop(url: URL) -> Bool {
        if let player = audioPlayers[url] {
            player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
            return player.numberOfLoops == -1
        }
        return false
    }
    
    /// Wird aufgerufen, wenn ein `AVAudioPlayer` die Wiedergabe beendet hat.
    /// - Parameters:
    ///   - player: Der Player, der die Wiedergabe beendet hat.
    ///   - flag: `true`, wenn die Wiedergabe erfolgreich beendet wurde.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Entfernt den Player aus dem Dictionary, wenn die Wiedergabe beendet ist.
        if let url = audioPlayers.first(where: { $0.value == player })?.key {
            audioPlayers.removeValue(forKey: url)
        }
    }
}
