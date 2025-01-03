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
        VStack(spacing: 20) {
            Text("Anmelden (ShadowWisperJournals)")
                .font(.largeTitle)
                .bold()

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

            Button(action: {
                userViewModel.loginShadowWisperUser(email: email, password: password)
            }) {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button("Noch kein Konto? Hier registrieren") {
                isRegisterViewActive = true
            }
            .foregroundColor(.blue)
        }
        .padding()
        .sheet(isPresented: $isRegisterViewActive) {
            ShadowWisperRegisterView()
                .environmentObject(userViewModel)
        }
    }
}
