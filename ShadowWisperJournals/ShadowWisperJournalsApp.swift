//
//  ShadowWisperJournalsApp.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//


import SwiftUI
import Firebase

@main
struct ShadowWisperJournalsApp: App {
    @StateObject private var userViewModel = ShadowWisperUserViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userViewModel)
        }
    }
}
