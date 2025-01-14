//
//  AddCharacterView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// Test

import SwiftUI

struct AddCharacterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var characterVM: CharacterViewModel
    let userId: String

    @State private var name: String = ""

    // Allgemeine Daten
    @State private var streetName: String = ""
    @State private var metaType: String = ""
    @State private var specialization: String = ""
    @State private var magicOrResonance: String = ""
    @State private var gender: String = ""
    @State private var height: Int? = nil
    @State private var weight: Int? = nil
    @State private var age: Int? = nil
    @State private var reputation: Int? = nil
    @State private var wantedLevel: Int? = nil
    @State private var karma: Int? = nil
    @State private var essence: Double? = nil

    // Attribute
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

    // Skill-Punkte
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

    // Ausrüstung, Hintergrund
    @State private var equipmentString: String = ""
    @State private var backstory: String = ""

    // Bild-Upload
    @State private var showImagePicker = false
    @State private var localSelectedImage: UIImage?
    @State private var errorMessage: String?
    
    // Profilbild
       @State private var showProfileImagePicker = false
       @State private var localProfileImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                            Section("Profilbild") {
                                Button("Profilbild auswählen") {
                                    showProfileImagePicker = true
                                }
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

                Section("Ausrüstung") {
                    TextField("Ausrüstung (Kommagetrennt)", text: $equipmentString)
                }

                Section("Hintergrundgeschichte") {
                    TextEditor(text: $backstory)
                        .frame(minHeight: 100)
                }
                
                // Galerie-Bilder
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

                                Section {
                                    Button("Charakter hinzufügen") {
                                        addCharacterAndUploadImage()
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Abbrechen", role: .cancel) {
                                        dismiss()
                                    }
                                }
                            }
                            .navigationTitle("Neuer Charakter")
                        }
                    }

                    private func addCharacterAndUploadImage() {
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

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            characterVM.fetchCharacters(for: userId)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if let newChar = characterVM.characters.first(where: {
                                    $0.name == self.name && $0.userId == self.userId
                                }) {
                                    if let localProfileImage = localProfileImage {
                                        characterVM.uploadProfileImage(localProfileImage, for: newChar) { result in
                                            switch result {
                                            case .success:
                                                break
                                            case .failure(let error):
                                                errorMessage = "Fehler beim Profilbild-Upload: \(error.localizedDescription)"
                                            }
                                        }
                                    }

                                    if let image = localSelectedImage {
                                        characterVM.uploadImage(image, for: newChar) { result in
                                            switch result {
                                            case .success:
                                                break
                                            case .failure(let error):
                                                errorMessage = "Fehler beim Hochladen (Galerie): \(error.localizedDescription)"
                                            }
                                            dismiss()
                                        }
                                    } else {
                                        dismiss()
                                    }
                                } else {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
