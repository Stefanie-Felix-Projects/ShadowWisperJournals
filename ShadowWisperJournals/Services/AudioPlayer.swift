//
//  AudioPlayer.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    var audioPlayers: [AVAudioPlayer] = []
    
    func playSound(url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.play()
            audioPlayers.append(player)
        } catch {
            print("Fehler beim Abspielen des Sounds: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = audioPlayers.firstIndex(of: player) {
            audioPlayers.remove(at: index)
        }
    }
}
