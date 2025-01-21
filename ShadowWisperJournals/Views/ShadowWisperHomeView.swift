//
//  ShadowWisperHomeView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

struct ShadowWisperHomeView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    private let tileGridColumns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        Text("ShadowWisperJournals")
                            .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                            .foregroundColor(AppColors.signalColor4)
                            .padding(.top, 20)
                        
                        Text("Willkommen, \(userViewModel.displayName ?? "Benutzer")!")
                            .font(.custom("SmoochSans-Bold", size: 25, relativeTo: .title))
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: tileGridColumns, spacing: 40) {
                            NavigationLink(destination: QuestLogDashboardView()) {
                                TileView(systemImage: "list.bullet.rectangle")
                            }
                            
                            NavigationLink(
                                destination: ChatOverviewView()
                                    .environmentObject(userViewModel)
                            ) {
                                TileView(systemImage: "bubble.left.and.bubble.right.fill")
                            }
                            
                            NavigationLink(destination: CharakteruebersichtView()) {
                                TileView(systemImage: "person.2.fill")
                            }
                            
                            NavigationLink(destination: SoundView()) {
                                TileView(systemImage: "headphones")
                            }
                        }
                        .frame(maxWidth: 600)
                        .padding(.top, 40)
                        
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
                .background(Color.clear)
                .scrollContentBackground(.hidden)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}

struct TileView: View {
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
