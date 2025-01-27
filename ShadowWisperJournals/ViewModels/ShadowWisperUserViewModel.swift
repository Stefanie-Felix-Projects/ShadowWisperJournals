//
//  ShadowWisperUserViewModel.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
// 

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation

/// `ShadowWisperUserViewModel` ist eine ViewModel-Klasse zur Verwaltung von Benutzerdaten
/// in der ShadowWisperJournals-App. Sie ermöglicht:
/// - Anmeldung und Registrierung von Benutzern
/// - Verwaltung und Abruf von Benutzerdaten aus Firestore
/// - Authentifizierungsprüfung und Benutzerabmeldung
class ShadowWisperUserViewModel: ObservableObject {
    
    // MARK: - Published Properties
    /// Der aktuell authentifizierte Benutzer (falls vorhanden).
    @Published var user: FireUser?
    
    /// Eine Fehlermeldung, falls eine Operation fehlschlägt.
    @Published var errorMessage: String?
    
    /// Der Anzeigename des aktuellen Benutzers.
    @Published var displayName: String?
    
    /// Gibt an, ob der Benutzer erfolgreich authentifiziert wurde.
    @Published var isAuthenticated: Bool = false
    
    /// Gibt an, ob die Authentifizierungsprüfung läuft.
    @Published var isCheckingAuth: Bool = true
    
    /// Gibt an, ob das Registrierungsformular angezeigt werden soll.
    @Published var shouldShowRegistration: Bool = false
    
    /// Gibt an, ob die Registrierung erfolgreich war.
    @Published var registrationSuccess: Bool = false
    
    // MARK: - Private Properties
    /// Firestore-Instanz zur Interaktion mit der Datenbank.
    private let db = Firestore.firestore()
    
    /// ViewModel zur Verwaltung der Journal-Einträge, falls erforderlich.
    private var journalViewModel: ShadowWisperJournalViewModel?
    
    // MARK: - Computed Properties
    /// Die ID des aktuell angemeldeten Benutzers.
    var userId: String? {
        user?.id
    }
    
    // MARK: - Initializer
    /// Initialisiert das ViewModel und prüft die Authentifizierung.
    init() {
        checkShadowWisperAuth()
    }
    
    // MARK: - Verknüpfung mit JournalViewModel
    /// Verknüpft das UserViewModel mit einem JournalViewModel, um Journal-Einträge zu laden.
    /// - Parameter viewModel: Das `ShadowWisperJournalViewModel`, das verwendet werden soll.
    func setJournalViewModel(_ viewModel: ShadowWisperJournalViewModel) {
        self.journalViewModel = viewModel
    }
    
    // MARK: - Benutzerverwaltung
    /// Meldet einen Benutzer mit E-Mail und Passwort an.
    /// - Parameters:
    ///   - email: Die E-Mail-Adresse des Benutzers.
    ///   - password: Das Passwort des Benutzers.
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
    
    /// Registriert einen neuen Benutzer mit den angegebenen Daten.
    /// - Parameters:
    ///   - email: Die E-Mail-Adresse des Benutzers.
    ///   - password: Das Passwort des Benutzers.
    ///   - displayName: Der Anzeigename des Benutzers.
    ///   - birthDate: Das Geburtsdatum des Benutzers (optional, Standard: aktuelles Datum).
    ///   - gender: Das Geschlecht des Benutzers (optional, Standard: "Unbekannt").
    ///   - profession: Der Beruf des Benutzers (optional, Standard: "N/A").
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
    
    /// Erstellt einen neuen Benutzer in der Firestore-Datenbank.
    /// - Parameters:
    ///   - id: Die Benutzer-ID.
    ///   - displayName: Der Anzeigename des Benutzers.
    ///   - birthDate: Das Geburtsdatum des Benutzers.
    ///   - gender: Das Geschlecht des Benutzers.
    ///   - profession: Der Beruf des Benutzers.
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
    
    /// Ruft die Benutzerdaten eines bestimmten Benutzers aus Firestore ab.
    /// - Parameter id: Die Benutzer-ID.
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
    
    /// Prüft, ob ein Benutzer aktuell authentifiziert ist.
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
    
    /// Meldet den aktuellen Benutzer ab.
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
