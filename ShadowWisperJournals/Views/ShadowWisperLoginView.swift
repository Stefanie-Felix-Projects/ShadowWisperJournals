//
//  ShadowWisperLoginView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

/**
 `ShadowWisperLoginView` bietet die Möglichkeit, sich in der ShadowWisperJournals-App anzumelden.
 
 **Funktionen**:
 - Eingabe von E-Mail und Passwort
 - Fehleranzeige (falls `userViewModel.errorMessage` gesetzt ist)
 - Login-Button, der `userViewModel.loginShadowWisperUser(email:password:)` aufruft
 - Button zum Aufruf der Registrierung (`ShadowWisperRegisterView`) via Sheet
 */
struct ShadowWisperLoginView: View {
    
    // MARK: - EnvironmentObject
    
    /// Das `userViewModel` verwaltet den Anmelde- und Registrierungsprozess sowie Fehlerzustände.
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - State
    
    /// E-Mail-Eingabe für den Login.
    @State private var email: String = ""
    
    /// Passwort-Eingabe für den Login.
    @State private var password: String = ""
    
    /// Steuert, ob die Registrierungsansicht (`ShadowWisperRegisterView`) als Sheet angezeigt wird.
    @State private var isRegisterViewActive = false
    
    // MARK: - Body
    
    /**
     Der UI-Aufbau erfolgt über eine `ZStack`, in der ein animierter Farbverlauf den Hintergrund bildet
     und ein `VStack` die Eingabefelder sowie Buttons enthält:
     
     1. **Titel** (ShadowWisperJournals)
     2. **Fehlermeldung** (falls vorhanden)
     3. **Eingabefelder** (E-Mail und Passwort)
     4. **Login-Button** (ruft `userViewModel.loginShadowWisperUser` auf)
     5. **Registrierungs-Button** (öffnet `ShadowWisperRegisterView` in einem Sheet)
     */
    var body: some View {
        ZStack {
            // Animierter Hintergrund
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // App-Titel
                Text("ShadowWisperJournals")
                    .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                    .foregroundColor(AppColors.signalColor4)
                
                // Fehlermeldung, falls vorhanden
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // E-Mail-Eingabe
                TextField("E-Mail", text: $email)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                
                // Passwort-Eingabe
                SecureField("Passwort", text: $password)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Login-Button
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
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .shadow(
                            color: AppColors.signalColor1.opacity(0.8),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                
                // Button für den Wechsel zur Registrierung
                Button("Noch kein Konto? Hier registrieren") {
                    isRegisterViewActive = true
                }
                .foregroundColor(AppColors.signalColor2)
                .font(.custom("SmoochSans-Regular", size: 18))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            // Registrierungsview als Sheet
            .sheet(isPresented: $isRegisterViewActive) {
                ShadowWisperRegisterView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
