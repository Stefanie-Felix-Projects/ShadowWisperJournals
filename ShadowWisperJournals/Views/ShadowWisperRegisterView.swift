//
//  ShadowWisperRegisterView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

struct ShadowWisperRegisterView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    
    var body: some View {
        ZStack {
            // Animierter Hintergrund wie im Login
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Titel analog zum Login
                Text("ShadowWisperJournals")
                    .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                    .foregroundColor(AppColors.signalColor4)
                
                // Optionaler "Registrieren"-Untertitel (falls gewünscht)
                Text("Registrieren")
                    .font(.custom("SmoochSans-Bold", size: 25, relativeTo: .title))
                    .foregroundColor(.white)
                
                // Fehlernachricht falls vorhanden
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Eingabefelder
                TextField("E-Mail", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                
                SecureField("Passwort", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Anzeigename", text: $displayName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Neon-Glow-Button analog zum Login
                Button {
                    userViewModel.registerShadowWisperUser(
                        email: email,
                        password: password,
                        displayName: displayName
                    )
                } label: {
                    Text("Registrieren")
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
                        .foregroundColor(.black) // Schwarzer Text für den Kontrast
                        .cornerRadius(8)
                        .shadow(
                            color: AppColors.signalColor1.opacity(0.8),
                            radius: 10,
                            x: 0,
                            y: 5
                        ) // Neon-Glow-Effekt
                }
            }
            .padding()
        }
    }
}
