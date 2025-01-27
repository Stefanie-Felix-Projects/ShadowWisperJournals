//
//  ShadowWisperHomeView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

/**
 `ShadowWisperHomeView` ist die zentrale Startseite (Home Screen) für eingeloggte Nutzer:innen.
 
 **Funktionen**:
 - Anzeige einer Willkommensnachricht mit dem angezeigten Namen des/der Nutzers:in
 - Schnellzugriff auf verschiedene Teilbereiche der App über eine grid-basierte Navigation
 - Ausloggen-Button, der den/die Nutzer:in abmeldet (via `logoutShadowWisperUser()`)
 
 **Aufbau**:
 - Ein `ScrollView` für vertikales Scrolling
 - Ein `VStack` mit Titel, Willkommensnachricht und einem `LazyVGrid` für die Navigationskacheln
 - Einzelne NavigationLinks führen zu:
 - `QuestLogDashboardView`
 - `ChatOverviewView`
 - `CharakteruebersichtView`
 - `SoundView`
 */
struct ShadowWisperHomeView: View {
    
    /// Liefert Informationen über den/die aktuell eingeloggte:n Nutzer:in (z. B. displayName).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - Layout für die Kachelansicht
    /**
     Definiert zwei gleichbreite Spalten mit 20 pt Abstand für das `LazyVGrid`,
     in dem die Navigationskacheln angezeigt werden.
     */
    private let tileGridColumns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    // MARK: - Body
    
    /**
     Der Hauptinhalt wird in einem `NavigationStack` dargestellt und enthält:
     1. Einen animierten Hintergrund (`AnimatedBackgroundView`)
     2. Eine ScrollView mit einem vertikalen Stack:
     - App-Titel (ShadowWisperJournals)
     - Willkommensnachricht (mit dem Anzeigenamen des Nutzers)
     - `LazyVGrid` mit vier Kacheln (Navigationslinks)
     - Logout-Button
     */
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund mit animiertem Farbverlauf
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                // Scrollbarer Inhalt
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // App-Titel
                        Text("ShadowWisperJournals")
                            .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                            .foregroundColor(AppColors.signalColor4)
                            .padding(.top, 20)
                        
                        // Willkommensnachricht
                        Text("Willkommen, \(userViewModel.displayName ?? "Benutzer")!")
                            .font(.custom("SmoochSans-Bold", size: 25, relativeTo: .title))
                            .foregroundColor(.white)
                        
                        // Navigationskacheln in einem grid
                        LazyVGrid(columns: tileGridColumns, spacing: 40) {
                            // Kachel 1: QuestLog
                            NavigationLink(destination: QuestLogDashboardView()) {
                                TileView(systemImage: "list.bullet.rectangle")
                            }
                            // Kachel 2: Chats
                            NavigationLink(
                                destination: ChatOverviewView()
                                    .environmentObject(userViewModel)
                            ) {
                                TileView(systemImage: "bubble.left.and.bubble.right.fill")
                            }
                            // Kachel 3: Charakterübersicht
                            NavigationLink(destination: CharakteruebersichtView()) {
                                TileView(systemImage: "person.2.fill")
                            }
                            // Kachel 4: SoundView
                            NavigationLink(destination: SoundView()) {
                                TileView(systemImage: "headphones")
                            }
                        }
                        .frame(maxWidth: 600)
                        .padding(.top, 40)
                        
                        // Logout-Button
                        Button(action: {
                            userViewModel.logoutShadowWisperUser()
                        }) {
                            Text("Abmelden")
                                .font(.custom("SmoochSans-Bold", size: 30, relativeTo: .largeTitle))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            AppColors.signalColor1,
                                            AppColors.signalColor5
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.black)
                                .cornerRadius(8)
                                .shadow(
                                    color: AppColors.signalColor1.opacity(0.8),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 50)
                    }
                    .padding(.horizontal, 16)
                }
                // Entfernt Hintergrund der ScrollView
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                // NavigationBar-Layout
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}

/**
 `TileView` stellt eine einzelne Kachel im `LazyVGrid` dar.
 
 **Aufbau**:
 - Ein SF-Symbol als Icon
 - Ein Farbverlauf-Hintergrund
 - Eckige Umrandung und Schatten
 */
struct TileView: View {
    /// Name des SF Symbols, das angezeigt werden soll (z. B. "bubble.left.and.bubble.right.fill")
    let systemImage: String
    
    var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .foregroundColor(.black)
            .frame(width: 50, height: 50)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.signalColor1,
                        AppColors.signalColor5
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(8)
            .shadow(
                color: AppColors.signalColor1.opacity(0.8),
                radius: 10,
                x: 0,
                y: 5
            )
    }
}
