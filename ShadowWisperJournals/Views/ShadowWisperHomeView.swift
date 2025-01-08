//
//  ShadowWisperHomeView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

struct ShadowWisperHomeView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    Text(
                        "Willkommen, \(userViewModel.displayName ?? "Benutzer")!"
                    )
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)

                    NavigationLink(
                        "QuestLog Dashboard",
                        destination: QuestLogDashboardView())

                    NavigationLink(
                        "Chatübersicht", destination: ChatOverviewView()
                    )
                    .environmentObject(userViewModel)

                    NavigationLink(
                        "Charakterübersicht",
                        destination: CharakteruebersichtView())
                    NavigationLink("Soundbereich", destination: SoundView())

                    VStack(spacing: 8) {
                        Text("Benachrichtigungen / Updates")
                            .font(.headline)

                        Text(
                            "Hier könnte ein kurzer Überblick über neueste Nachrichten, Updates oder Kampagnen-Infos stehen."
                        )
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)

                    Button(action: {
                        userViewModel.logoutShadowWisperUser()
                    }) {
                        Text("Abmelden")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("ShadowWisper Startseite")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
