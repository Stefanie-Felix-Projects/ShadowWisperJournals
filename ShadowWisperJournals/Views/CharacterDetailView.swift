//
//  CharacterDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct CharacterDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var characterVM = CharacterViewModel()
    
    var character: Character
    
    // Allgemeine Daten
    @State private var name: String
    @State private var streetName: String
    @State private var metaType: String
    @State private var specialization: String
    @State private var magicOrResonance: String
    @State private var gender: String
    @State private var height: Int?
    @State private var weight: Int?
    @State private var age: Int?
    @State private var reputation: Int?
    @State private var wantedLevel: Int?
    @State private var karma: Int?
    @State private var essence: Double?
    
    // Attribute
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
    
    // Skills
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
    
    // Ausrüstung, Backstory
    @State private var equipmentString: String
    @State private var backstory: String
    
    // Profilbild
    @State private var showProfilePicker = false
    @State private var localProfileImage: UIImage?
    
    // Bild-Upload
    @State private var localSelectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var errorMessage: String?
    
    @State private var selectedImageURL: URL?
    @State private var showFullScreenImage: Bool = false
    
    init(character: Character) {
        self.character = character
        
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
        
        // Ausrüstung & Backstory
        _equipmentString = State(initialValue: (character.equipment ?? []).joined(separator: ", "))
        _backstory = State(initialValue: character.backstory ?? "")
    }
    
    var body: some View {
        Form {
            Section("Profilbild") {
                if let profileURL = character.profileImageURL, let url = URL(string: profileURL) {
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
                
                Button("Neues Profilbild wählen") {
                    showProfilePicker = true
                }
                .sheet(isPresented: $showProfilePicker) {
                    ImagePicker { selectedImage in
                        self.localProfileImage = selectedImage
                    }
                }
                
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
            Section("Allgemeine Daten") {
                TextField("Name (Realname)", text: $name)
                TextField("Straßenname", text: $streetName)
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
            
            // Attribute
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
            
            // Skills
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
            
            // Ausrüstung
            Section("Ausrüstung") {
                TextField("Ausrüstung (Kommagetrennt)", text: $equipmentString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            // Hintergrundgeschichte
            Section("Hintergrundgeschichte") {
                TextEditor(text: $backstory)
                    .frame(minHeight: 100)
            }
            
            // Bilder anzeigen
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
            
            // Neues Bild hinzufügen
            Section("Neues Bild hinzufügen") {
                Button("Bild aus Fotobibliothek") {
                    showImagePicker = true
                }
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
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Hochladen") {
                    uploadImageIfNeeded()
                }
                .disabled(localSelectedImage == nil)
            }
            
            Section {
                Button("Speichern") {
                    saveCharacterData()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Löschen", role: .destructive) {
                    characterVM.deleteCharacter(character)
                    dismiss()
                }
            }
        }
        .navigationTitle("Charakter bearbeiten")
        .sheet(isPresented: $showFullScreenImage) {
            if let url = selectedImageURL {
                LargeImageView(imageURL: url, title: character.name)
            }
        }
        .onAppear {
            if !character.userId.isEmpty {
                characterVM.fetchCharacters(for: character.userId)
            }
        }
    }
    
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
        
        // Ausrüstung + Backstory
        let equipmentArray = equipmentString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        updatedCharacter.equipment = equipmentArray.isEmpty ? nil : equipmentArray
        updatedCharacter.backstory = backstory
        
        characterVM.updateCharacter(updatedCharacter)
        dismiss()
    }
    
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

struct CharacterLargeImageView: View {
    let imageURL: URL
    let title: String
    
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
