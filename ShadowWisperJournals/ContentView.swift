//
//  ContentView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// Test

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel

    var body: some View {
        VStack {
            Text("Willkommen, \(userViewModel.displayName ?? "Benutzer")!")
                .font(.largeTitle)
                .padding()

            Button("Abmelden") {
                userViewModel.logoutShadowWisperUser()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)

            Text("Hier könnte das Shadowrun-Kampagnenmanagement starten...")
                .padding()
        }
        .padding()
    }
}
