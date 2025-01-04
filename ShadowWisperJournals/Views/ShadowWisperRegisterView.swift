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
        VStack {
            Text("Registrieren (ShadowWisperJournals)")
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
            
            TextField("Anzeigename", text: $displayName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Button("Registrieren") {
                userViewModel.registerShadowWisperUser(
                    email: email,
                    password: password,
                    displayName: displayName
                )
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()

    }
}
