//
//  RootView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

/**
 `RootView` entscheidet anhand des `userViewModel`-Zustands, welche Ansicht
 dargestellt wird. Die möglichen Ansichten sind:
 - `ShadowWisperRegisterView` (falls eine Registrierung angezeigt werden soll)
 - `ShadowWisperHomeView` (falls der Nutzer bereits eingeloggt ist)
 - `ShadowWisperLoginView` (falls ein Login erfolgen muss)
 
 Zusätzlich wird beim Erscheinen der View (`.onAppear`) die Funktion
 `checkShadowWisperAuth()` aufgerufen, um den aktuellen Authentifizierungsstatus
 zu überprüfen.
 */
struct RootView: View {
    
    /// Verwaltet den Zustand des Nutzers (z. B. eingeloggt, Registrierung nötig, etc.)
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - Body
    var body: some View {
        ZStack {
            /// Ein animierter Hintergrund mit Farbverlauf
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            /// Hauptinhalt: Abhängig vom Zustand des `userViewModel`
            VStack {
                if userViewModel.shouldShowRegistration {
                    // Nutzer soll Registrierungsbildschirm sehen
                    ShadowWisperRegisterView()
                } else if userViewModel.isAuthenticated {
                    // Nutzer ist eingeloggt
                    ShadowWisperHomeView()
                } else {
                    // Nutzer ist weder registriert noch eingeloggt
                    ShadowWisperLoginView()
                }
            }
        }
        // MARK: - onAppear
        .onAppear {
            // Prüft den aktuellen Authentifizierungsstatus
            userViewModel.checkShadowWisperAuth()
        }
    }
}

// MARK: - Vorschau
#Preview {
    RootView()
        .environmentObject(ShadowWisperUserViewModel())
}
