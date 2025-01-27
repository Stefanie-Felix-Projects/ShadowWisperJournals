//
//  AssignCharactersSheetView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `AssignCharactersSheetView` ist eine View, die es Benutzern ermöglicht,
/// Charaktere einer bestimmten Quest zuzuweisen. Sie wird in einem modalen Blatt angezeigt.
///
/// Hauptfunktionen:
/// - Integration einer animierten Hintergrundansicht.
/// - Bereitstellung des Hauptinhalts durch `AssignCharactersView`.
/// - Verwaltung von Daten durch mehrere ViewModel-Instanzen.
struct AssignCharactersSheetView: View {
    
    /// Die Quest, zu der Charaktere zugewiesen werden sollen.
    var quest: Quest
    
    // MARK: - EnvironmentObjects
    /// ViewModel für die Verwaltung von Quests.
    @EnvironmentObject var questLogVM: QuestLogViewModel
    
    /// ViewModel für die Verwaltung von Charakteren.
    @EnvironmentObject var characterVM: CharacterViewModel
    
    /// ViewModel für Benutzerdaten.
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    var body: some View {
        ZStack {
            // MARK: - Hintergrund
            /// Animierte Hintergrundansicht mit Farbverlauf.
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea() // Hintergrund erstreckt sich über den gesamten Bildschirm
            
            // MARK: - Hauptinhalt
            /// View für die Zuweisung von Charakteren zu einer Quest.
            AssignCharactersView(quest: quest)
                .environmentObject(questLogVM) // Weitergabe des QuestLog-ViewModels
                .environmentObject(characterVM) // Weitergabe des Character-ViewModels
                .environmentObject(userViewModel) // Weitergabe des User-ViewModels
                .background(Color.clear) // Transparenter Hintergrund
        }
    }
}
