//
//  AddQuestView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

/**
 `AddQuestView` stellt ein Formular zum Erstellen neuer Quests bereit.
 Nutzer:innen können folgende Informationen eingeben:
 - Titel der Quest
 - Beschreibung
 - Status (Aktiv oder Abgeschlossen)
 - Optionale Belohnung
 - Zuordnung zu bestimmten Charakteren
 - Optionales Bild hochladen
 - Standort über Textfeld und GoogleMapView
 
 Weiterhin wird ein Toast angezeigt, wenn das Hinzufügen erfolgreich war.
 */
struct AddQuestView: View {
    
    // MARK: - Environment & ObservedObject
    
    /// Environment-Variable, um diese View zu schließen.
    @Environment(\.dismiss) var dismiss
    
    /// Das User-ViewModel verwaltet Informationen über den aktuell eingeloggten Nutzer.
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    /// Das Character-ViewModel stellt die Liste aller Charaktere und zugehörige Methoden bereit.
    @EnvironmentObject var characterVM: CharacterViewModel
    
    /// Das QuestLog-ViewModel verwaltet Quests (Anlegen, Bearbeiten, Löschen, Bilder hochladen etc.).
    @ObservedObject var questLogVM: QuestLogViewModel
    
    /// Die User-ID des aktuell angemeldeten Nutzers, zu dem die Quest gespeichert werden soll.
    let userId: String
    
    // MARK: - State Variablen (Quest-Daten)
    
    /// Titel der Quest.
    @State private var title: String = ""
    
    /// Beschreibung der Quest.
    @State private var description: String = ""
    
    /// Aktueller Status der Quest, z.B. "aktiv" oder "abgeschlossen".
    @State private var status: String = "aktiv"
    
    /// Optionale Belohnung. Ist leer, wenn keine Belohnung eingetragen wurde.
    @State private var reward: String = ""
    
    /// Liste der ausgewählten Charakter-IDs, die an der Quest teilnehmen.
    @State private var selectedCharacterIds: [String] = []
    
    // MARK: - State Variablen (Bild-Upload)
    
    /// Steuert die Anzeige des ImagePickers.
    @State private var showImagePicker = false
    
    /// Lokal ausgewähltes Bild (aus der Fotobibliothek), das hochgeladen werden soll.
    @State private var localSelectedImage: UIImage?
    
    /// Fehlermeldung bei fehlerhaftem Upload oder fehlenden Eingaben.
    @State private var errorMessage: String?
    
    // MARK: - State Variablen (Standort)
    
    /// Standort als String, der in der GoogleMapView angezeigt werden soll.
    @State private var locationString: String = ""
    
    // MARK: - State Variablen (UI/Feedback)
    
    /// Steuert das Anzeigen eines Toasts bei erfolgreichem Hinzufügen der Quest.
    @State private var showToast: Bool = false
    
    // MARK: - Body
    
    /**
     Der View-Aufbau erfolgt über eine `NavigationStack` mit einem `ScrollView`.
     Darin werden mehrere Bereiche (`VStack`) angezeigt:
     - **Quest-Details**: Titel, Beschreibung, Status, Belohnung
     - **Charaktere zuweisen**: Liste aller vorhandenen Charaktere (togglebar)
     - **Bild hinzufügen**: Optionales Bild hochladen und Vorschau
     - **Standort**: Textfeld + GoogleMapView
     - **Button "Quest hinzufügen"**: Validierung und Speichern
     
     Bei Erfolg wird ein Toast eingeblendet, bei Abbruch wird die View dismissed.
     */
    var body: some View {
        ZStack {
            // Hintergrund-View mit animiertem Farbverlauf
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: Quest-Details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quest-Details")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            /// Eingabefeld für den Quest-Titel
                            TextField("Titel der Quest", text: $title)
                                .font(.custom("SmoochSans-Bold", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            /// Eingabefeld für die Quest-Beschreibung
                            TextField("Beschreibung", text: $description)
                                .font(.custom("SmoochSans-Regular", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            /// Picker für den Quest-Status (aktiv/abgeschlossen)
                            Picker("Status", selection: $status) {
                                Text("Aktiv").tag("aktiv")
                                Text("Abgeschlossen").tag("abgeschlossen")
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 8)
                            
                            /// Eingabefeld für die (optionale) Belohnung
                            TextField("Belohnung", text: $reward)
                                .font(.custom("SmoochSans-Bold", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // MARK: Charaktere zuweisen
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Charaktere zuweisen")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            let availableCharacters = characterVM.characters
                            
                            /// Falls keine Charaktere vorhanden sind, zeige eine Info
                            if availableCharacters.isEmpty {
                                Text("Keine Charaktere verfügbar.")
                                    .font(.custom("SmoochSans-Regular", size: 16))
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(availableCharacters, id: \.id) { character in
                                    let cId = character.id ?? ""
                                    
                                    /// Custom Row für jeden Charakter mit Toggle-Selection
                                    CharacterRow(
                                        character: character,
                                        isSelected: selectedCharacterIds.contains(cId),
                                        toggleSelection: {
                                            if selectedCharacterIds.contains(cId) {
                                                selectedCharacterIds.removeAll { $0 == cId }
                                            } else {
                                                selectedCharacterIds.append(cId)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // MARK: Bild hinzufügen
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bild hinzufügen")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            /// Button zum Öffnen des ImagePickers
                            Button(action: {
                                showImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .foregroundColor(.black)
                                    Text("Bild aus Fotobibliothek")
                                        .font(.custom("SmoochSans-Bold", size: 22))
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
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
                                .cornerRadius(8)
                                .shadow(
                                    color: AppColors.signalColor1.opacity(0.8),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                            }
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker { selectedImage in
                                    self.localSelectedImage = selectedImage
                                }
                            }
                            
                            /// Zeige eine Vorschau des ausgewählten Bildes oder einen Platzhalter
                            if let localImage = localSelectedImage {
                                Text("Vorschau (noch nicht hochgeladen):")
                                    .font(.custom("SmoochSans-Regular", size: 16))
                                    .foregroundColor(.secondary)
                                
                                Image(uiImage: localImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                                    .cornerRadius(8)
                            } else {
                                Text("Kein lokales Bild ausgewählt")
                                    .font(.custom("SmoochSans-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // MARK: Standort
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Standort")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            /// Eingabefeld für die Adresse / Ort.
                            /// Wird an die GoogleMapView weitergegeben.
                            TextField("Adresse / Ort eingeben", text: $locationString)
                                .font(.custom("SmoochSans-Regular", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never)
                            
                            /// Zeigt die Karte basierend auf dem eingegebenen Standort (locationString).
                            GoogleMapView(locationString: locationString)
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // MARK: Fehleranzeige (falls vorhanden)
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.custom("SmoochSans-Regular", size: 16))
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // MARK: Quest hinzufügen Button
                        Button(action: {
                            /// Validierung: Titel und Beschreibung dürfen nicht leer sein.
                            guard !title.isEmpty, !description.isEmpty else {
                                errorMessage = "Titel und Beschreibung dürfen nicht leer sein."
                                return
                            }
                            
                            /// Neue Quest über das ViewModel hinzufügen
                            questLogVM.addQuest(
                                title: title,
                                description: description,
                                status: status,
                                reward: reward.isEmpty ? nil : reward,
                                userId: userId,
                                creatorDisplayName: userViewModel.user?.displayName,
                                assignedCharacterIds: selectedCharacterIds.isEmpty ? nil : selectedCharacterIds,
                                locationString: locationString
                            ) { result in
                                switch result {
                                case .success(let newQuestId):
                                    // Wenn erfolgreich hinzugefügt, optional Bild hochladen
                                    if let image = localSelectedImage {
                                        let newQuest = Quest(
                                            id: newQuestId,
                                            title: title,
                                            description: description,
                                            status: status,
                                            createdAt: Date(),
                                            userId: userId,
                                            reward: reward.isEmpty ? nil : reward,
                                            creatorDisplayName: userViewModel.user?.displayName,
                                            assignedCharacterIds: selectedCharacterIds.isEmpty ? nil : selectedCharacterIds,
                                            imageURLs: [],
                                            locationString: locationString
                                        )
                                        questLogVM.uploadImage(image, for: newQuest) { uploadResult in
                                            switch uploadResult {
                                            case .success(let imageURL):
                                                // Quest mit neuer ImageURL aktualisieren
                                                var updatedQuest = newQuest
                                                updatedQuest.imageURLs = [imageURL]
                                                questLogVM.updateQuest(updatedQuest)
                                                dismiss()
                                                
                                                // Toast anzeigen
                                                showToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        showToast = false
                                                    }
                                                }
                                            case .failure(let uploadError):
                                                errorMessage = "Fehler beim Hochladen des Bildes: \(uploadError.localizedDescription)"
                                            }
                                        }
                                    } else {
                                        // Wenn kein Bild ausgewählt, direkt dismiss
                                        dismiss()
                                        
                                        // Toast anzeigen
                                        showToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showToast = false
                                            }
                                        }
                                    }
                                    
                                case .failure(let error):
                                    errorMessage = "Fehler beim Hinzufügen der Quest: \(error.localizedDescription)"
                                }
                            }
                        }) {
                            Text("Quest hinzufügen")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
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
                                .cornerRadius(8)
                                .shadow(
                                    color: AppColors.signalColor1.opacity(0.8),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                        }
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Neue Quest")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        /// Button zum Abbrechen des Vorgangs
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .font(.custom("SmoochSans-Regular", size: 18))
                        .foregroundColor(AppColors.signalColor2)
                    }
                }
            }
            
            // MARK: Toast Overlay
            /// Overlay, das bei erfolgreichem Hinzufügen einer Quest eingeblendet wird.
            if showToast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Quest hinzugefügt!")
                            .font(.custom("SmoochSans-Regular", size: 18))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showToast)
                }
            }
        }
    }
}
