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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quest-Details") {
                    TextField("Titel der Quest", text: $title)
                    TextField("Beschreibung", text: $description)
                    TextField("Belohnung", text: $reward)
                }
                
                Section("Charaktere zuweisen") {
                    let availableCharacters = characterVM.characters
                    
                    if availableCharacters.isEmpty {
                        Text("Keine Charaktere verfügbar.")
                            .foregroundColor(.gray)
                    } else {
                        List(availableCharacters, id: \.id) { character in
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
                
                Section("Bild hinzufügen") {
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
                }
                
                Section("Standort") {
                    TextField("Adresse / Ort eingeben", text: $locationString)
                        .textInputAutocapitalization(.never)
                    
                    GoogleMapView(locationString: locationString)
                        .frame(height: 200)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Button("Quest hinzufügen") {
                    guard !title.isEmpty, !description.isEmpty else { return }
                    
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
                                    case .success:
                                        dismiss()
                                    case .failure(let uploadError):
                                        errorMessage = "Fehler beim Hochladen des Bildes: \(uploadError.localizedDescription)"
                                    }
                                }
                            } else {
                                dismiss()
                            }
                            
                        case .failure(let error):
                            errorMessage = "Fehler beim Hinzufügen der Quest: \(error.localizedDescription)"
                        }
                    }
                }
            }
            .navigationTitle("Neue Quest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}
