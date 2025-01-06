//
//  RootView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel

    var body: some View {
        VStack {
            if userViewModel.shouldShowRegistration {
                ShadowWisperRegisterView()
            } else if userViewModel.isAuthenticated {
                ShadowWisperHomeView()
            } else {
                ShadowWisperLoginView()
            }
        }
        .onAppear {
            userViewModel.checkShadowWisperAuth()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(ShadowWisperUserViewModel())
}
