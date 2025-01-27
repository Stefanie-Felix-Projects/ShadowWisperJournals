//
//  AddCharacterView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 Die `AddCharacterView` dient als Formularansicht, in der Benutzer:innen
 einen neuen Charakter erstellen und optional Profil- und/oder zusätzliche
 Bilder hochladen können.
 
 Sie beinhaltet mehrere Sektionen:
 - Profilbild auswählen
 - Allgemeine Daten (Name, Metatyp, Geschlecht etc.)
 - Attribute
 - Fertigkeiten
 - Ausrüstung & Hintergrundgeschichte
 - Ein Bild hochladen (Galerie)
 - Aktionen (Speichern und Abbrechen)
 
 Nach Eingabe aller Werte kann der Charakter inklusive der Bilder in Firestore
 (bzw. in deinem ViewModel) gespeichert werden.
 */
struct AddCharacterView: View {
    
    // MARK: - Environment & ObservedObject
    
    /// Ermöglicht das Schließen bzw. Dismissen der aktuellen View.
    @Environment(\.dismiss) var dismiss
    
    /// Das ViewModel zum Verwalten der Charaktere. Hierüber erfolgt das Hinzufügen und Uploaden.
    @ObservedObject var characterVM: CharacterViewModel
    
    /// Die ID des aktuell eingeloggten Nutzers, zu dem der neue Charakter hinzugefügt werden soll.
    let userId: String
    
    // MARK: - Allgemeine Charakterdaten
    
    /// Der Realname des Charakters.
    @State private var name: String = ""
    
    /// Der Straßenname (Alias) des Charakters.
    @State private var streetName: String = ""
    
    /// Der Metatyp des Charakters (z.B. Mensch, Elf, Ork, Zwerg etc.).
    @State private var metaType: String = ""
    
    /// Freies Textfeld für die Spezialisierung (z.B. Hacker, Rigger, Decker, Schamane).
    @State private var specialization: String = ""
    
    /// Freies Textfeld für die Angabe, ob der Charakter Magie oder Resonanz besitzt.
    @State private var magicOrResonance: String = ""
    
    /// Geschlecht des Charakters.
    @State private var gender: String = ""
    
    /// Körpergröße in Zentimetern.
    @State private var height: Int? = nil
    
    /// Körpergewicht in Kilogramm.
    @State private var weight: Int? = nil
    
    /// Alter des Charakters.
    @State private var age: Int? = nil
    
    /// Ruf des Charakters (z.B. bei Shadowrun relevant für Kontakte und Reputation).
    @State private var reputation: Int? = nil
    
    /// Fahndungsstufe bei Behörden (je höher, desto gefährlicher für den Charakter).
    @State private var wantedLevel: Int? = nil
    
    /// Aktueller Karma-Stand (zur Steigerung von Attributen, Skills etc.).
    @State private var karma: Int? = nil
    
    /// Essenzwert des Charakters (bei Cyberware/Magie relevant).
    @State private var essence: Double? = nil
    
    // MARK: - Attribute
    
    /**
     Nachfolgend die Grundattribute und weitere Werte, die sich auf verschiedene
     Spielemechaniken auswirken können (z.B. in Shadowrun).
     
     Alle Attribute werden hier über ein `Stepper` angepasst und sind standardmäßig
     zwischen 0 und 50 limitiert.
     */
    
    @State private var konstitution: Int = 0
    @State private var geschicklichkeit: Int = 0
    @State private var reaktion: Int = 0
    @State private var staerke: Int = 0
    @State private var willenskraft: Int = 0
    @State private var logik: Int = 0
    @State private var intuition: Int = 0
    @State private var charisma: Int = 0
    @State private var edge: Int = 0
    @State private var nebenhandlungen: Int = 0
    @State private var iniHotCold: Int = 0
    @State private var iniMatrixVR: Int = 0
    @State private var iniAstral: Int = 0
    @State private var verteidigung: Int = 0
    @State private var selbstbeherrschung: Int = 0
    @State private var menschenkenntnis: Int = 0
    @State private var erinnerungsvermoegen: Int = 0
    @State private var hebenTragen: Int = 0
    
    // MARK: - Skills
    
    /**
     Auflistung von Fertigkeiten (Skills), die im Spiel verwendet werden.
     Alle Skills sind ebenfalls über `Stepper` editierbar.
     */
    
    @State private var biotech: Int = 0
    @State private var ersteHilfe: Int = 0
    @State private var athletik: Int = 0
    @State private var einfluss: Int = 0
    @State private var elektronik: Int = 0
    @State private var hardware: Int = 0
    @State private var feuerwaffen: Int = 0
    @State private var heimlichkeit: Int = 0
    @State private var mechanik: Int = 0
    @State private var nahkampf: Int = 0
    @State private var natur: Int = 0
    @State private var steuern: Int = 0
    @State private var wahrnehmung: Int = 0
    @State private var ueberreden: Int = 0
    
    // MARK: - Ausrüstung & Hintergrund
    
    /// String, in dem Ausrüstung kommasepariert eingegeben werden kann.
    @State private var equipmentString: String = ""
    
    /// Hintergrundgeschichte des Charakters.
    @State private var backstory: String = ""
    
    // MARK: - Bild-Upload States
    
    /**
     Zustände für das Anzeigen des Image Pickers (Fotobibliothek).
     - `showImagePicker`: Steuert, ob der Sheet für den Bildpicker angezeigt wird.
     - `localSelectedImage`: Das lokal ausgewählte Bild für die Bilder-Galerie.
     - `errorMessage`: Fehlermeldung beim Upload.
     */
    
    @State private var showImagePicker = false
    @State private var localSelectedImage: UIImage?
    @State private var errorMessage: String?
    
    /**
     Zustände für das Profilbild:
     - `showProfileImagePicker`: Steuert, ob der Sheet für den Profilbild-Picker angezeigt wird.
     - `localProfileImage`: Das lokal ausgewählte Profilbild.
     */
    @State private var showProfileImagePicker = false
    @State private var localProfileImage: UIImage?
    
    // MARK: - Body
    
    /**
     Der eigentliche View-Aufbau mit einem animierten Hintergrund und einer
     NavigationStack-basierten `Form`. Enthält mehrere `Section`s für die
     Eingabe der Charakterdaten, das Hochladen von Bildern und die
     abschließenden Aktionen (Speichern/Abbrechen).
     */
    var body: some View {
        ZStack {
            // Hintergrund-View mit animiertem Farbverlauf
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                Form {
                    
                    // MARK: - Profilbild
                    Section("Profilbild") {
                        /// Button zum Öffnen des Profilbild-Pickers
                        Button("Profilbild auswählen") {
                            showProfileImagePicker = true
                        }
                        // Sheet zum Auswählen des Profilbilds
                        .sheet(isPresented: $showProfileImagePicker) {
                            ImagePicker { selectedImage in
                                self.localProfileImage = selectedImage
                            }
                        }
                        
                        if let localProfile = localProfileImage {
                            Text("Profilbild-Vorschau (noch nicht hochgeladen):")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Image(uiImage: localProfile)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                        } else {
                            Text("Kein Profilbild ausgewählt")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // MARK: - Allgemeine Daten
                    Section("Allgemeine Daten") {
                        // Name & weitere Felder
                        TextField("Name (Realname)", text: $name)
                        TextField("Straßenname", text: $streetName)
                        TextField("Metatyp", text: $metaType)
                        TextField("Spezialisierung", text: $specialization)
                        TextField("Magie/Resonanz", text: $magicOrResonance)
                        TextField("Geschlecht", text: $gender)
                        
                        // Größe
                        HStack {
                            Text("Größe (cm)")
                            Spacer()
                            TextField("z.B. 180", value: $height, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Gewicht
                        HStack {
                            Text("Gewicht (kg)")
                            Spacer()
                            TextField("z.B. 80", value: $weight, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Alter
                        HStack {
                            Text("Alter")
                            Spacer()
                            TextField("z.B. 25", value: $age, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Ruf
                        HStack {
                            Text("Ruf")
                            Spacer()
                            TextField("z.B. 3", value: $reputation, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Fahndungsstufe
                        HStack {
                            Text("Fahndungsstufe")
                            Spacer()
                            TextField("z.B. 2", value: $wantedLevel, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Karma
                        HStack {
                            Text("Karma")
                            Spacer()
                            TextField("z.B. 10", value: $karma, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        // Essenz
                        HStack {
                            Text("Essenz")
                            Spacer()
                            TextField("z.B. 5.5", value: $essence, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // MARK: - Attribute
                    Section("Attribute") {
                        Stepper("Konstitution: \(konstitution)", value: $konstitution, in: 0...50)
                        Stepper("Geschicklichkeit: \(geschicklichkeit)", value: $geschicklichkeit, in: 0...50)
                        Stepper("Reaktion: \(reaktion)", value: $reaktion, in: 0...50)
                        Stepper("Stärke: \(staerke)", value: $staerke, in: 0...50)
                        Stepper("Willenskraft: \(willenskraft)", value: $willenskraft, in: 0...50)
                        Stepper("Logik: \(logik)", value: $logik, in: 0...50)
                        Stepper("Intuition: \(intuition)", value: $intuition, in: 0...50)
                        Stepper("Charisma: \(charisma)", value: $charisma, in: 0...50)
                        Stepper("Edge: \(edge)", value: $edge, in: 0...50)
                        Stepper("Nebenhandlungen: \(nebenhandlungen)", value: $nebenhandlungen, in: 0...50)
                        Stepper("Initiative Hot/Cold: \(iniHotCold)", value: $iniHotCold, in: 0...50)
                        Stepper("Initiative Matrix VR: \(iniMatrixVR)", value: $iniMatrixVR, in: 0...50)
                        Stepper("Initiative Astral: \(iniAstral)", value: $iniAstral, in: 0...50)
                        Stepper("Verteidigung: \(verteidigung)", value: $verteidigung, in: 0...50)
                        Stepper("Selbstbeherrschung: \(selbstbeherrschung)", value: $selbstbeherrschung, in: 0...50)
                        Stepper("Menschenkenntnis: \(menschenkenntnis)", value: $menschenkenntnis, in: 0...50)
                        Stepper("Erinnerungsvermögen: \(erinnerungsvermoegen)", value: $erinnerungsvermoegen, in: 0...50)
                        Stepper("Heben/Tragen: \(hebenTragen)", value: $hebenTragen, in: 0...50)
                    }
                    
                    // MARK: - Skills
                    Section("Fertigkeiten") {
                        Stepper("Biotech: \(biotech)", value: $biotech, in: 0...50)
                        Stepper("Erste Hilfe: \(ersteHilfe)", value: $ersteHilfe, in: 0...50)
                        Stepper("Athletik: \(athletik)", value: $athletik, in: 0...50)
                        Stepper("Einfluss: \(einfluss)", value: $einfluss, in: 0...50)
                        Stepper("Elektronik: \(elektronik)", value: $elektronik, in: 0...50)
                        Stepper("Hardware: \(hardware)", value: $hardware, in: 0...50)
                        Stepper("Feuerwaffen: \(feuerwaffen)", value: $feuerwaffen, in: 0...50)
                        Stepper("Heimlichkeit: \(heimlichkeit)", value: $heimlichkeit, in: 0...50)
                        Stepper("Mechanik: \(mechanik)", value: $mechanik, in: 0...50)
                        Stepper("Nahkampf: \(nahkampf)", value: $nahkampf, in: 0...50)
                        Stepper("Natur: \(natur)", value: $natur, in: 0...50)
                        Stepper("Steuern: \(steuern)", value: $steuern, in: 0...50)
                        Stepper("Wahrnehmung: \(wahrnehmung)", value: $wahrnehmung, in: 0...50)
                        Stepper("Überreden: \(ueberreden)", value: $ueberreden, in: 0...50)
                    }
                    
                    // MARK: - Ausrüstung
                    Section("Ausrüstung") {
                        TextField("Ausrüstung (Kommagetrennt)", text: $equipmentString)
                    }
                    
                    // MARK: - Hintergrund
                    Section("Hintergrundgeschichte") {
                        TextEditor(text: $backstory)
                            .frame(minHeight: 100)
                    }
                    
                    // MARK: - Neues Bild
                    Section("Neues Bild hinzufügen") {
                        /// Button zum Öffnen des Bild-Pickers für zusätzliche Bilder
                        Button("Bild aus Fotobibliothek") {
                            showImagePicker = true
                        }
                        // Sheet zum Auswählen eines Bildes
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker { selectedImage in
                                self.localSelectedImage = selectedImage
                            }
                        }
                        
                        if let localImage = localSelectedImage {
                            Text("Vorschau (noch nicht hochgeladen):")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Image(uiImage: localImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                        } else {
                            Text("Kein lokales Bild ausgewählt")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // MARK: - Aktionen
                    Section {
                        /// Erstellt einen neuen Charakter und lädt gegebenenfalls Bilder hoch.
                        Button("Charakter hinzufügen") {
                            addCharacterAndUploadImage()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        /// Bricht den Vorgang ab und schließt die View.
                        Button("Abbrechen", role: .cancel) {
                            dismiss()
                        }
                    }
                }
                // Entfernt den Hintergrund der Form-Abschnitte und setzt diesen auf transparent.
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Neuer Charakter")
            }
            .background(Color.clear)
        }
    }
    
    // MARK: - Funktionen
    
    /**
     Fügt dem ViewModel (`characterVM`) einen neuen Charakter hinzu und lädt
     anschließend (asynchron) das Profilbild und/oder weitere Bilder hoch, sofern
     sie ausgewählt wurden.
     
     Ablauf:
     1. Erstellen eines `attributes`-Dictionaries mit allen Attributen.
     2. Erstellen eines `skillPoints`-Dictionaries mit allen Fertigkeiten.
     3. Aufruf von `characterVM.addCharacter(...)` zum Speichern der Charakterdaten.
     4. Verzögerung, um sicherzustellen, dass der neue Charakter vom Server gelesen werden kann.
     5. Aktualisierung der Charakterliste (`fetchCharacters`).
     6. Bild-Uploads (Profilbild und/oder zusätzliches Bild), sofern vorhanden.
     7. Schließt die View (dismiss), wenn alles abgeschlossen ist.
     */
    private func addCharacterAndUploadImage() {
        // Dictionary für die Attribute
        let attributes: [String: Int] = [
            "konstitution": konstitution,
            "geschicklichkeit": geschicklichkeit,
            "reaktion": reaktion,
            "staerke": staerke,
            "willenskraft": willenskraft,
            "logik": logik,
            "intuition": intuition,
            "charisma": charisma,
            "edge": edge,
            "nebenhandlungen": nebenhandlungen,
            "iniHotCold": iniHotCold,
            "iniMatrixVR": iniMatrixVR,
            "iniAstral": iniAstral,
            "verteidigung": verteidigung,
            "selbstbeherrschung": selbstbeherrschung,
            "menschenkenntnis": menschenkenntnis,
            "erinnerungsvermoegen": erinnerungsvermoegen,
            "hebenTragen": hebenTragen
        ]
        
        // Dictionary für die Skills
        let skillPoints: [String: Int] = [
            "biotech": biotech,
            "ersteHilfe": ersteHilfe,
            "athletik": athletik,
            "einfluss": einfluss,
            "elektronik": elektronik,
            "hardware": hardware,
            "feuerwaffen": feuerwaffen,
            "heimlichkeit": heimlichkeit,
            "mechanik": mechanik,
            "nahkampf": nahkampf,
            "natur": natur,
            "steuern": steuern,
            "wahrnehmung": wahrnehmung,
            "ueberreden": ueberreden
        ]
        
        // Charakter zum ViewModel hinzufügen
        characterVM.addCharacter(
            name: name,
            attributes: attributes,
            skillPoints: skillPoints,
            backstory: backstory.isEmpty ? nil : backstory,
            userId: userId,
            streetName: streetName.isEmpty ? nil : streetName,
            metaType: metaType.isEmpty ? nil : metaType,
            specialization: specialization.isEmpty ? nil : specialization,
            magicOrResonance: magicOrResonance.isEmpty ? nil : magicOrResonance,
            gender: gender.isEmpty ? nil : gender,
            height: height,
            weight: weight,
            age: age,
            reputation: reputation,
            wantedLevel: wantedLevel,
            karma: karma,
            essence: essence
        )
        
        // Asynchrone Warteschleife, damit der Charakter auch in der Liste erscheint
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            characterVM.fetchCharacters(for: userId)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // Versuchen, den soeben erstellten Charakter in der aktualisierten Liste zu finden
                if let newChar = characterVM.characters.first(where: {
                    $0.name == self.name && $0.userId == self.userId
                }) {
                    // Falls ein Profilbild ausgewählt wurde, wird es hochgeladen
                    if let localProfileImage = localProfileImage {
                        characterVM.uploadProfileImage(localProfileImage, for: newChar) { result in
                            switch result {
                            case .success:
                                // Profilbild erfolgreich hochgeladen, kein weiteres Handling nötig
                                break
                            case .failure(let error):
                                errorMessage = "Fehler beim Profilbild-Upload: \(error.localizedDescription)"
                            }
                        }
                    }
                    
                    // Falls ein weiteres Bild aus der Galerie ausgewählt wurde, wird es hochgeladen
                    if let image = localSelectedImage {
                        characterVM.uploadImage(image, for: newChar) { result in
                            switch result {
                            case .success:
                                // Upload erfolgreich
                                break
                            case .failure(let error):
                                errorMessage = "Fehler beim Hochladen (Galerie): \(error.localizedDescription)"
                            }
                            // Nach Abschluss schließt sich die View
                            dismiss()
                        }
                    } else {
                        // Kein zusätzliches Bild, also nur schließen
                        dismiss()
                    }
                } else {
                    // Wenn kein passender Charakter gefunden wurde, die View schließen
                    dismiss()
                }
            }
        }
    }
}
