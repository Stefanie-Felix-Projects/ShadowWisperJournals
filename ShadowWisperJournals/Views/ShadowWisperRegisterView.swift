//
//  ShadowWisperRegisterView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

/**
 `ShadowWisperRegisterView` bietet ein Formular, über das sich neue Nutzer:innen für
 die ShadowWisperJournals-App registrieren können.

 **Funktionen**:
 - Eingabefelder für E-Mail, Passwort und Anzeigenamen
 - Darstellung einer Fehlermeldung, falls `userViewModel.errorMessage` gesetzt ist
 - Registrierungs-Button, der `registerShadowWisperUser(email:password:displayName:)` aufruft
 */
struct ShadowWisperRegisterView: View {
    
    // MARK: - EnvironmentObject
    
    /**
     Das `userViewModel` verwaltet alle Anmelde- und Registrierungsprozesse sowie
     mögliche Fehlermeldungen, falls die Registrierung fehlschlägt.
     */
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - State
    
    /// E-Mail-Eingabe
    @State private var email: String = ""
    
    /// Passwort-Eingabe
    @State private var password: String = ""
    
    /// Anzeigename (z. B. Benutzer- oder Rollenname)
    @State private var displayName: String = ""
    
    // MARK: - Body
    
    /**
     Das UI-Layout besteht aus einem `ZStack` mit einem animierten Hintergrund
     und einem `VStack`, das die Eingabefelder und den Button enthält:
     
     1. **App-Titel**: "ShadowWisperJournals"
     2. **Fehlermeldung** (falls vorhanden)
     3. **E-Mail**, **Passwort** und **Name** Eingabefelder
     4. **Registrierungs-Button**, welcher die `userViewModel.registerShadowWisperUser(...)`-Methode aufruft
     */
    var body: some View {
        ZStack {
            // Hintergrund (animierter Farbverlauf)
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // Titel
                Text("ShadowWisperJournals")
                    .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                    .foregroundColor(AppColors.signalColor4)
                
                // Fehlermeldung (falls vorhanden)
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // E-Mail-Feld
                TextField("E-Mail", text: $email)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                
                // Passwort-Feld
                SecureField("Passwort", text: $password)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Anzeigename-Feld
                TextField("Name", text: $displayName)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Registrieren-Button
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
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .shadow(
                            color: AppColors.signalColor1.opacity(0.8),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
            }
            .padding()
        }
    }
}
