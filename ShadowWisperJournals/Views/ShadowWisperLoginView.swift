//
//  ShadowWisperLoginView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

struct ShadowWisperLoginView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegisterViewActive = false
    
    var body: some View {
        ZStack {
            // => Animierter Hintergrund
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            // Hauptinhalt
            VStack(spacing: 20) {
                
                Text("ShadowWisperJournals")
                    .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                    .foregroundColor(AppColors.signalColor4) // Titel in knalliger Farbe
                
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Neon-Glow Button
                Button {
                    userViewModel.loginShadowWisperUser(email: email, password: password)
                } label: {
                    Text("Login")
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
                        .foregroundColor(.black) // Schwarzer Text für Kontrast
                        .cornerRadius(8)
                        .shadow(
                            color: AppColors.signalColor1.opacity(0.8),
                            radius: 10,
                            x: 0,
                            y: 5
                        ) // Neon-Glow-Effekt
                }
                
                // Registrieren-Link
                Button("Noch kein Konto? Hier registrieren") {
                    isRegisterViewActive = true
                }
                .foregroundColor(AppColors.signalColor2)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            // => Sheet für die Registrierung
            .sheet(isPresented: $isRegisterViewActive) {
                ShadowWisperRegisterView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
