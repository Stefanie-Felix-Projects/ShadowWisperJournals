//
//  ShadowWisperJournalsApp.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import Firebase
import SwiftUI

@main
struct ShadowWisperJournalsApp: App {
    // NEU:
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // Dein ViewModel etc.
    @StateObject private var userViewModel = ShadowWisperUserViewModel()

    init() {
        // Wenn du Firebase hier initialisieren willst:
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userViewModel)
        }
    }
}
