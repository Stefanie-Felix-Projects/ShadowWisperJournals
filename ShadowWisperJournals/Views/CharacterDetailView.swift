//
//  CharacterDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

/**
 `CharacterDetailView` bietet eine detaillierte Ansicht und Bearbeitungsoptionen
 für einen bestehenden Charakter. Hier können sowohl generelle Informationen
 (z.B. Name, Metatyp, Geschlecht etc.) als auch Attribute, Skills, Ausrüstung
 und Hintergrundgeschichte editiert werden.
 
 Zusätzlich lassen sich Profilbilder und weitere Bilder hochladen oder anzeigen.
 */
struct CharacterDetailView: View {
    
    // MARK: - Environment & ObservedObject
    
    /// Ermöglicht das Dismiss (Schließen) der aktuellen View.
    @Environment(\.dismiss) var dismiss
    
    /// Das Character-ViewModel zum Verwalten, Aktualisieren und Hochladen von Charakter-Daten.
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - Übergebener Charakter
    
    /// Der zu bearbeitende Charakter. Dieser Wert wird via init in die View injiziert.
    var character: Character
    
    // MARK: - Allgemeine Daten
    
    /// Name (Realname) des Charakters.
    @State private var name: String
    
    /// Straßenname (Alias) des Charakters.
    @State private var streetName: String
    
    /// Metatyp des Charakters (z.B. Mensch, Elf, Ork, etc.).
    @State private var metaType: String
    
    /// Spezialisierung (z.B. Hacker, Schamane, Rigger ...).
    @State private var specialization: String
    
    /// Magie oder Resonanz (falls vorhanden).
    @State private var magicOrResonance: String
    
    /// Geschlecht des Charakters.
    @State private var gender: String
    
    /// Körpergröße in Zentimetern.
    @State private var height: Int?
    
    /// Gewicht in Kilogramm.
    @State private var weight: Int?
    
    /// Alter des Charakters.
    @State private var age: Int?
    
    /// Rufstufe (z.B. für Bekanntheit).
    @State private var reputation: Int?
    
    /// Fahndungsstufe bei Behörden.
    @State private var wantedLevel: Int?
    
    /// Aktueller Karmawert.
    @State private var karma: Int?
    
    /// Essenzwert (relevant bei Cyberware/Magie).
    @State private var essence: Double?
    
    // MARK: - Attribute
    
    /**
     Nachfolgend alle Attribute, die über einen `Stepper` angepasst werden können.
     Sie sind in einem Bereich von 0 bis 50 begrenzt.
     */
    @State private var konstitution: Int
    @State private var geschicklichkeit: Int
    @State private var reaktion: Int
    @State private var staerke: Int
    @State private var willenskraft: Int
    @State private var logik: Int
    @State private var intuition: Int
    @State private var charisma: Int
    @State private var edge: Int
    @State private var nebenhandlungen: Int
    @State private var iniHotCold: Int
    @State private var iniMatrixVR: Int
    @State private var iniAstral: Int
    @State private var verteidigung: Int
    @State private var selbstbeherrschung: Int
    @State private var menschenkenntnis: Int
    @State private var erinnerungsvermoegen: Int
    @State private var hebenTragen: Int
    
    // MARK: - Skills
    
    /// Fertigkeitenbereiche, ebenfalls konfiguriert über `Stepper`.
    @State private var biotech: Int
    @State private var ersteHilfe: Int
    @State private var athletik: Int
    @State private var einfluss: Int
    @State private var elektronik: Int
    @State private var hardware: Int
    @State private var feuerwaffen: Int
    @State private var heimlichkeit: Int
    @State private var mechanik: Int
    @State private var nahkampf: Int
    @State private var natur: Int
    @State private var steuern: Int
    @State private var wahrnehmung: Int
    @State private var ueberreden: Int
    
    // MARK: - Ausrüstung & Backstory
    
    /// Kommaseparierte Liste an Ausrüstungsgegenständen.
    @State private var equipmentString: String
    
    /// Hintergrundgeschichte des Charakters.
    @State private var backstory: String
    
    // MARK: - Profilbild
    
    /// Steuert die Anzeige des Image-Pickers für das Profilbild.
    @State private var showProfilePicker = false
    
    /// Lokal ausgewähltes Profilbild, das ggf. hochgeladen wird.
    @State private var localProfileImage: UIImage?
    
    // MARK: - Bild-Upload (Galerie)
    
    /// Lokal ausgewähltes Bild aus der Fotobibliothek (nicht das Profilbild).
    @State private var localSelectedImage: UIImage?
    
    /// Steuert die Anzeige des Image-Pickers für Galerie-Bilder.
    @State private var showImagePicker = false
    
    /// Fehlermeldung, z.B. bei fehlgeschlagenem Bild-Upload.
    @State private var errorMessage: String?
    
    /// URL für ein ausgewähltes Bild, um es in voller Größe anzuzeigen.
    @State private var selectedImageURL: URL?
    
    /// Steuert, ob ein Bild in voller Größe angezeigt wird (Vollbild).
    @State private var showFullScreenImage: Bool = false
    
    // MARK: - Initializer
    
    /**
     Der Initializer sorgt dafür, dass alle `@State`-Variablen
     korrekt mit den Daten des übergebenen `Character` befüllt werden.
     
     - Parameter character: Der zu bearbeitende Charakter.
     */
    init(character: Character) {
        self.character = character
        
        // Hilfsfunktionen zum Laden von Attributen und Skills
        func val(_ key: String) -> Int {
            character.attributes?[key] ?? 0
        }
        func skillVal(_ key: String) -> Int {
            character.skillPoints?[key] ?? 0
        }
        
        // Allgemeine Daten
        _name = State(initialValue: character.name)
        _streetName = State(initialValue: character.streetName ?? "")
        _metaType = State(initialValue: character.metaType ?? "")
        _specialization = State(initialValue: character.specialization ?? "")
        _magicOrResonance = State(initialValue: character.magicOrResonance ?? "")
        _gender = State(initialValue: character.gender ?? "")
        _height = State(initialValue: character.height)
        _weight = State(initialValue: character.weight)
        _age = State(initialValue: character.age)
        _reputation = State(initialValue: character.reputation)
        _wantedLevel = State(initialValue: character.wantedLevel)
        _karma = State(initialValue: character.karma)
        _essence = State(initialValue: character.essence)
        
        // Attribute
        _konstitution = State(initialValue: val("konstitution"))
        _geschicklichkeit = State(initialValue: val("geschicklichkeit"))
        _reaktion = State(initialValue: val("reaktion"))
        _staerke = State(initialValue: val("staerke"))
        _willenskraft = State(initialValue: val("willenskraft"))
        _logik = State(initialValue: val("logik"))
        _intuition = State(initialValue: val("intuition"))
        _charisma = State(initialValue: val("charisma"))
        _edge = State(initialValue: val("edge"))
        _nebenhandlungen = State(initialValue: val("nebenhandlungen"))
        _iniHotCold = State(initialValue: val("iniHotCold"))
        _iniMatrixVR = State(initialValue: val("iniMatrixVR"))
        _iniAstral = State(initialValue: val("iniAstral"))
        _verteidigung = State(initialValue: val("verteidigung"))
        _selbstbeherrschung = State(initialValue: val("selbstbeherrschung"))
        _menschenkenntnis = State(initialValue: val("menschenkenntnis"))
        _erinnerungsvermoegen = State(initialValue: val("erinnerungsvermoegen"))
        _hebenTragen = State(initialValue: val("hebenTragen"))
        
        // Skills
        _biotech = State(initialValue: skillVal("biotech"))
        _ersteHilfe = State(initialValue: skillVal("ersteHilfe"))
        _athletik = State(initialValue: skillVal("athletik"))
        _einfluss = State(initialValue: skillVal("einfluss"))
        _elektronik = State(initialValue: skillVal("elektronik"))
        _hardware = State(initialValue: skillVal("hardware"))
        _feuerwaffen = State(initialValue: skillVal("feuerwaffen"))
        _heimlichkeit = State(initialValue: skillVal("heimlichkeit"))
        _mechanik = State(initialValue: skillVal("mechanik"))
        _nahkampf = State(initialValue: skillVal("nahkampf"))
        _natur = State(initialValue: skillVal("natur"))
        _steuern = State(initialValue: skillVal("steuern"))
        _wahrnehmung = State(initialValue: skillVal("wahrnehmung"))
        _ueberreden = State(initialValue: skillVal("ueberreden"))
        
        // Ausrüstung & Hintergrundgeschichte
        _equipmentString = State(
            initialValue: (character.equipment ?? [])
                .joined(separator: ", ")
        )
        _backstory = State(initialValue: character.backstory ?? "")
    }
    
    // MARK: - Body
    
    /**
     Der UI-Aufbau erfolgt mit einem `NavigationStack`, in dem ein `Form`-Layout eingebettet ist:
     - **Profilbild-Sektion**: Anzeige und ggf. Hochladen eines Profilbildes
     - **Allgemeine Daten**: Standardattribute wie Name, Geschlecht, Größe usw.
     - **Attribute**: Stepper für Konstitution, Reaktion, etc.
     - **Fertigkeiten**: Stepper für diverse Skills (Biotech, Erste Hilfe, etc.)
     - **Ausrüstung**: Kommaseparierte Eingabe
     - **Hintergrundgeschichte**: Freitext
     - **Hochgeladene Bilder**: Anzeige bereits hochgeladener Bilder, inkl. Fullscreen-Vorschau
     - **Neues Bild hinzufügen**: Möglichkeit zum Auswählen und Hochladen
     - **Aktionen**: Speichern und Löschen
     */
    var body: some View {
        NavigationStack {
            ZStack {
                // Animierter Hintergrund
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                Form {
                    // MARK: Profilbild
                    Section("Profilbild") {
                        /// Zeigt das aktuelle Profilbild oder ein Standard-Symbol
                        if let profileURL = character.profileImageURL,
                           let url = URL(string: profileURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        /// Button für das Auswählen eines neuen Profilbilds
                        Button("Neues Profilbild wählen") {
                            showProfilePicker = true
                        }
                        .sheet(isPresented: $showProfilePicker) {
                            ImagePicker { selectedImage in
                                self.localProfileImage = selectedImage
                            }
                        }
                        
                        /// Zeigt ein Vorschaubild und einen Upload-Button, falls ein neues Profilbild ausgewählt wurde
                        if let localImage = localProfileImage {
                            Text("Vorschau (noch nicht hochgeladen):")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Image(uiImage: localImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                            
                            Button("Als Profilbild hochladen") {
                                uploadProfileImageIfNeeded()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    // MARK: Allgemeine Daten
                    Section("Allgemeine Daten") {
                        TextField("Name (Straßenname)", text: $name)
                        TextField("Realname", text: $streetName)
                        TextField("Metatyp", text: $metaType)
                        TextField("Spezialisierung", text: $specialization)
                        TextField("Magie/Resonanz", text: $magicOrResonance)
                        TextField("Geschlecht", text: $gender)
                        
                        HStack {
                            Text("Größe (cm)")
                            Spacer()
                            TextField("z.B. 180", value: $height, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Gewicht (kg)")
                            Spacer()
                            TextField("z.B. 80", value: $weight, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Alter")
                            Spacer()
                            TextField("z.B. 25", value: $age, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Ruf")
                            Spacer()
                            TextField("z.B. 3", value: $reputation, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Fahndungsstufe")
                            Spacer()
                            TextField("z.B. 2", value: $wantedLevel, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Karma")
                            Spacer()
                            TextField("z.B. 10", value: $karma, format: .number)
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Essenz")
                            Spacer()
                            TextField("z.B. 5.5", value: $essence, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // MARK: Attribute
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
                    
                    // MARK: Skills
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
                    
                    // MARK: Ausrüstung
                    Section("Ausrüstung") {
                        TextField("Ausrüstung (Kommagetrennt)", text: $equipmentString)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    
                    // MARK: Hintergrundgeschichte
                    Section("Hintergrundgeschichte") {
                        TextEditor(text: $backstory)
                            .frame(minHeight: 100)
                    }
                    
                    // MARK: Hochgeladene Bilder
                    Section("Hochgeladene Bilder") {
                        if let urls = character.imageURLs, !urls.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(urls, id: \.self) { urlString in
                                        if let url = URL(string: urlString) {
                                            Button {
                                                selectedImageURL = url
                                                showFullScreenImage = true
                                            } label: {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                            .frame(width: 100, height: 100)
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 100, height: 100)
                                                            .clipped()
                                                            .cornerRadius(8)
                                                    case .failure:
                                                        Image(systemName: "photo.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 100, height: 100)
                                                            .foregroundColor(.gray)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            .frame(height: 120)
                        } else {
                            Text("Keine Bilder vorhanden.")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // MARK: Neues Bild hinzufügen
                    Section("Neues Bild hinzufügen") {
                        Button("Bild aus Fotobibliothek") {
                            showImagePicker = true
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker { selectedImage in
                                self.localSelectedImage = selectedImage
                            }
                        }
                        
                        // Vorschau des lokal ausgewählten Bildes
                        if let localImage = localSelectedImage {
                            Text("Vorschau (noch nicht hochgeladen):")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Image(uiImage: localImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(8)
                        }
                        
                        // Fehlermeldung falls vorhanden
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                        
                        // Button zum Hochladen des ausgewählten Bildes
                        Button("Hochladen") {
                            uploadImageIfNeeded()
                        }
                        .disabled(localSelectedImage == nil)
                    }
                    
                    // MARK: Aktionen
                    Section {
                        /// Button zum Speichern der geänderten Charakterdaten.
                        Button("Speichern") {
                            saveCharacterData()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        /// Button zum Löschen des Charakters aus der Datenbank.
                        Button("Löschen", role: .destructive) {
                            characterVM.deleteCharacter(character)
                            dismiss()
                        }
                    }
                }
                // Entfernt oder ändert den Hintergrund des Forms
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .navigationTitle("Charakter bearbeiten")
            }
            .background(Color.clear)
        }
        .onAppear {
            // Bei Erscheinen der View werden (falls userId existiert) alle Charaktere neu geladen
            if !character.userId.isEmpty {
                characterVM.fetchCharacters(for: character.userId)
            }
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    /**
     Lädt das lokal ausgewählte Profilbild hoch, falls vorhanden,
     und setzt den lokalen State zurück bei Erfolg.
     */
    private func uploadProfileImageIfNeeded() {
        guard let localProfileImage = localProfileImage else { return }
        
        characterVM.uploadProfileImage(localProfileImage, for: character) { result in
            switch result {
            case .success:
                self.localProfileImage = nil
            case .failure(let error):
                print("Fehler beim Profilbild hochladen: \(error.localizedDescription)")
            }
        }
    }
    
    /**
     Validiert und speichert alle aktuell eingegebenen Daten in einem
     aktualisierten `Character`-Objekt. Anschließend wird das ViewModel
     angewiesen, den Charakter zu aktualisieren.
     */
    private func saveCharacterData() {
        var updatedCharacter = character
        
        // Allgemeine Daten
        updatedCharacter.name = name
        updatedCharacter.streetName = streetName.isEmpty ? nil : streetName
        updatedCharacter.metaType = metaType.isEmpty ? nil : metaType
        updatedCharacter.specialization = specialization.isEmpty ? nil : specialization
        updatedCharacter.magicOrResonance = magicOrResonance.isEmpty ? nil : magicOrResonance
        updatedCharacter.gender = gender.isEmpty ? nil : gender
        updatedCharacter.height = height
        updatedCharacter.weight = weight
        updatedCharacter.age = age
        updatedCharacter.reputation = reputation
        updatedCharacter.wantedLevel = wantedLevel
        updatedCharacter.karma = karma
        updatedCharacter.essence = essence
        
        // Attribute
        updatedCharacter.attributes = [
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
        
        // Skills
        updatedCharacter.skillPoints = [
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
        
        // Ausrüstung & Hintergrundgeschichte
        let equipmentArray = equipmentString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        updatedCharacter.equipment = equipmentArray.isEmpty ? nil : equipmentArray
        updatedCharacter.backstory = backstory
        
        // Update via ViewModel
        characterVM.updateCharacter(updatedCharacter)
        dismiss()
    }
    
    /**
     Lädt ein neu ausgewähltes Bild in die Galerie-Bilder des Charakters hoch,
     sofern ein Bild vorhanden ist. Andernfalls wird eine Fehlermeldung gesetzt.
     */
    private func uploadImageIfNeeded() {
        guard let image = localSelectedImage else { return }
        
        characterVM.uploadImage(image, for: character) { result in
            switch result {
            case .success:
                self.localSelectedImage = nil
            case .failure(let error):
                self.errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Vollbild‐Ansicht für ein Bild (optional)

/**
 `CharacterLargeImageView` stellt ein ausgewähltes Bild in voller Größe dar.
 Es kann via Navigation geschlossen werden.
 */
struct CharacterLargeImageView: View {
    /// URL des anzuzeigenden Bildes.
    let imageURL: URL
    
    /// Titel, der in der Navigationsleiste angezeigt wird.
    let title: String
    
    /// Ermöglicht das Dismiss der Vollbild-Ansicht.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .scaleEffect(1.5)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .background(Color.black)
                        .ignoresSafeArea(edges: .bottom)
                case .failure:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red)
                @unknown default:
                    EmptyView()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
    }
}
