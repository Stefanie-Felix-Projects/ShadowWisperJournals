//
//  ShadowWisperUserViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class ShadowWisperUserViewModel: ObservableObject {

    @Published var user: FireUser?
    @Published var errorMessage: String?
    @Published var displayName: String?
    @Published var isAuthenticated: Bool = false
    @Published var isCheckingAuth: Bool = true
    
    @Published var shouldShowRegistration: Bool = false
    
    @Published var registrationSuccess: Bool = false
    
    private let db = Firestore.firestore()
    private var journalViewModel: ShadowWisperJournalViewModel?

    var userId: String? {
        user?.id
    }

    init() {
        checkShadowWisperAuth()
    }

    func setJournalViewModel(_ viewModel: ShadowWisperJournalViewModel) {
        self.journalViewModel = viewModel
    }

    func loginShadowWisperUser(email: String, password: String) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Bitte E-Mail und Passwort eingeben."
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Anmeldung fehlgeschlagen: \(error.localizedDescription)"
                return
            }
            guard let authResult = authResult else { return }
            self.fetchShadowWisperUser(id: authResult.user.uid)
        }
    }

    func registerShadowWisperUser(
        email: String,
        password: String,
        displayName: String,
        birthDate: Date = Date(),
        gender: String = "Unbekannt",
        profession: String = "N/A"
    ) {
        guard !email.isEmpty, !password.isEmpty, !displayName.isEmpty else {
            self.errorMessage = "Bitte alle Felder ausfüllen."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Registrierung fehlgeschlagen: \(error.localizedDescription)"
                return
            }
            guard let authResult = authResult else { return }
            
            self.registrationSuccess = true

            self.createShadowWisperUser(
                id: authResult.user.uid,
                displayName: displayName,
                birthDate: birthDate,
                gender: gender,
                profession: profession
            )

            self.fetchShadowWisperUser(id: authResult.user.uid)
        }
    }

    private func createShadowWisperUser(
        id: String,
        displayName: String,
        birthDate: Date,
        gender: String,
        profession: String
    ) {
        let fireUser = FireUser(
            id: id,
            registeredOn: Date(),
            displayName: displayName,
            birthDate: birthDate,
            gender: gender,
            profession: profession
        )

        do {
            try db.collection("users").document(id).setData(from: fireUser)
        } catch {
            self.errorMessage = "Fehler beim Speichern der Benutzerdaten: \(error.localizedDescription)"
        }
    }

    func fetchShadowWisperUser(id: String) {
        db.collection("users").document(id).getDocument { document, error in
            if let error = error {
                self.errorMessage = "Fehler beim Laden der Benutzerdaten: \(error.localizedDescription)"
                return
            }
            guard let document = document, document.exists else {
                self.errorMessage = "Benutzer nicht gefunden, bitte registrieren."
                self.shouldShowRegistration = true
                return
            }

            do {
                self.user = try document.data(as: FireUser.self)
                self.displayName = self.user?.displayName
                self.isAuthenticated = true
                
                if let userId = self.user?.id {
                    self.journalViewModel?.fetchJournalEntries(for: userId)
                }
            } catch {
                self.errorMessage = "Fehler beim Konvertieren der Benutzerdaten: \(error.localizedDescription)"
            }
        }
    }

    func checkShadowWisperAuth() {
        self.isCheckingAuth = true
        if let currentUser = Auth.auth().currentUser {
            let userId = currentUser.uid
            self.fetchShadowWisperUser(id: userId)
        } else {
            self.isAuthenticated = false
        }
        self.isCheckingAuth = false
    }

    func logoutShadowWisperUser() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.displayName = nil
            self.isAuthenticated = false
            self.shouldShowRegistration = false
          
            self.registrationSuccess = false
            journalViewModel?.removeListener()
        } catch {
            self.errorMessage = "Abmeldung fehlgeschlagen: \(error.localizedDescription)"
        }
    }
}
