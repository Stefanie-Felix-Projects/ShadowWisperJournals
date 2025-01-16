//
//  AudioPlayer.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    @Published var audioPlayers: [URL: AVAudioPlayer] = [:]
    
    func playSound(url: URL, loop: Bool = false) {
        do {
            if let existingPlayer = audioPlayers[url], existingPlayer.isPlaying {
                existingPlayer.stop()
            }
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.numberOfLoops = loop ? -1 : 0
            player.play()
            audioPlayers[url] = player
        } catch {
            print("Fehler beim Abspielen des Sounds: \(error)")
        }
    }
    
    func pauseSound(url: URL) {
        if let player = audioPlayers[url], player.isPlaying {
            player.pause()
        }
    }
    
    func stopSound(url: URL) {
        if let player = audioPlayers[url] {
            player.stop()
            audioPlayers.removeValue(forKey: url)
        }
    }
    
    func toggleLoop(url: URL) -> Bool {
        if let player = audioPlayers[url] {
            player.numberOfLoops = player.numberOfLoops == 0 ? -1 : 0
            return player.numberOfLoops == -1
        }
        return false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let url = audioPlayers.first(where: { $0.value == player })?.key {
            audioPlayers.removeValue(forKey: url)
        }
    }
}
