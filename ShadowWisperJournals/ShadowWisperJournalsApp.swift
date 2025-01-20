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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userViewModel = ShadowWisperUserViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userViewModel)
                // Hier die "globale" Font setzen:
                .environment(\.font,
                             .custom("SmoochSans-Regular", size: 16)
                )
        }
    }
}
