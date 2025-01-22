//
//  AddQuestView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI

struct AddQuestView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    @EnvironmentObject var characterVM: CharacterViewModel
    
    @ObservedObject var questLogVM: QuestLogViewModel
    let userId: String
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var status: String = "aktiv"
    @State private var reward: String = ""
    
    @State private var selectedCharacterIds: [String] = []
    @State private var showImagePicker = false
    @State private var localSelectedImage: UIImage?
    @State private var errorMessage: String?
    @State private var locationString: String = ""
    
    @State private var showToast: Bool = false // Hinzugefügt für Toast
    
    var body: some View {
        ZStack {
            // Hintergrund mit Animation
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Quest-Details Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quest-Details")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            TextField("Titel der Quest", text: $title)
                                .font(.custom("SmoochSans-Bold", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            TextField("Beschreibung", text: $description)
                                .font(.custom("SmoochSans-Regular", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            // Beibehalten des bestehenden Pickers
                            Picker("Status", selection: $status) {
                                Text("Aktiv").tag("aktiv")
                                Text("Abgeschlossen").tag("abgeschlossen")
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical, 8)
                            
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
                        
                        // Charaktere zuweisen Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Charaktere zuweisen")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            let availableCharacters = characterVM.characters
                            
                            if availableCharacters.isEmpty {
                                Text("Keine Charaktere verfügbar.")
                                    .font(.custom("SmoochSans-Regular", size: 16))
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(availableCharacters, id: \.id) { character in
                                    let cId = character.id ?? ""
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
                        
                        // Bild hinzufügen Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Bild hinzufügen")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
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
                        
                        // Standort Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Standort")
                                .font(.custom("SmoochSans-Bold", size: 22))
                                .foregroundColor(AppColors.signalColor4)
                            
                            TextField("Adresse / Ort eingeben", text: $locationString)
                                .font(.custom("SmoochSans-Regular", size: 20))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never)
                            
                            GoogleMapView(locationString: locationString)
                                .frame(height: 200)
                                .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                        
                        // Fehlermeldung Section
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.custom("SmoochSans-Regular", size: 16))
                                .foregroundColor(.red)
                                .padding()
                        }
                        
                        // Quest hinzufügen Button
                        Button(action: {
                            guard !title.isEmpty, !description.isEmpty else {
                                errorMessage = "Titel und Beschreibung dürfen nicht leer sein."
                                return
                            }
                            
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
                                                // Aktualisiere die Quest mit der ImageURL
                                                var updatedQuest = newQuest
                                                updatedQuest.imageURLs = [imageURL]
                                                questLogVM.updateQuest(updatedQuest)
                                                dismiss()
                                                
                                                // Zeige Toast bei erfolgreichem Hinzufügen
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
                                        dismiss()
                                        
                                        // Zeige Toast bei erfolgreichem Hinzufügen ohne Bild
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
                        Button("Abbrechen") {
                            dismiss()
                        }
                        .font(.custom("SmoochSans-Regular", size: 18))
                        .foregroundColor(AppColors.signalColor2)
                    }
                }
            }
            
            // Toast Overlay direkt im ZStack platzieren, außerhalb des NavigationStack
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
