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
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("ShadowWisperJournals")
                    .font(.custom("SmoochSans-Bold", size: 40, relativeTo: .largeTitle))
                    .foregroundColor(AppColors.signalColor4)
                
                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                TextField("E-Mail", text: $email)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .keyboardType(.emailAddress)
                
                SecureField("Passwort", text: $password)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
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
                
                Button("Noch kein Konto? Hier registrieren") {
                    isRegisterViewActive = true
                }
                .foregroundColor(AppColors.signalColor2)
                .font(.system(size: 16))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .sheet(isPresented: $isRegisterViewActive) {
                ShadowWisperRegisterView()
                    .environmentObject(userViewModel)
            }
        }
    }
}
