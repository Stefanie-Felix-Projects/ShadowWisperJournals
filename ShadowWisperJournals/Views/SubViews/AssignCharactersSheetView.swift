//
//  AssignCharactersSheetView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct AssignCharactersSheetView: View {
    var quest: Quest
    @EnvironmentObject var questLogVM: QuestLogViewModel
    @EnvironmentObject var characterVM: CharacterViewModel
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            AssignCharactersView(quest: quest)
                .environmentObject(questLogVM)
                .environmentObject(characterVM)
                .environmentObject(userViewModel)
                .background(Color.clear)
        }
    }
}
