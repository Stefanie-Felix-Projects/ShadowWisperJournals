//
//  QuestDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI
import UniformTypeIdentifiers
struct QuestDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    @ObservedObject var questLogVM: QuestLogViewModel
    @EnvironmentObject var characterVM: CharacterViewModel
    
    var quest: Quest
    
    @State private var title: String
    @State private var description: String
    @State private var status: String
    @State private var reward: String
    
    @State private var showAssignCharactersSheet = false
    @State private var showImagePicker = false
    
    @State private var localSelectedImage: UIImage?

    @State private var isDropTargeted: Bool = false
    
    @State private var errorMessage: String?
    
    init(quest: Quest, questLogVM: QuestLogViewModel) {
        self.quest = quest
        self._questLogVM = ObservedObject(wrappedValue: questLogVM)
        
        _title = State(initialValue: quest.title)
        _description = State(initialValue: quest.description)
        _status = State(initialValue: quest.status)
        _reward = State(initialValue: quest.reward ?? "")
    }
    
    var body: some View {
        Form {
            Section("Quest-Details") {
                TextField("Titel", text: $title)
                TextField("Beschreibung", text: $description)
                
                Picker("Status", selection: $status) {
                    Text("Aktiv").tag("aktiv")
                    Text("Abgeschlossen").tag("abgeschlossen")
                }
                .pickerStyle(.segmented)
                
                TextField("Belohnung", text: $reward)
            }
            
            if let creatorName = quest.creatorDisplayName {
                Section("Erstellt von") {
                    Text(creatorName)
                        .font(.headline)
                }
            }
            
            Section("Zugewiesene Charaktere") {
                if let assignedCharacterIds = quest.assignedCharacterIds,
                   !assignedCharacterIds.isEmpty {
                    ForEach(assignedCharacterIds, id: \.self) { charId in
                        if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                            Text(foundChar.name)
                        } else {
                            Text("Unbekannter Charakter (ID: \(charId))")
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Text("Keine Charaktere zugewiesen.")
                        .foregroundColor(.gray)
                }
                
                Button("Charaktere zuweisen") {
                    showAssignCharactersSheet = true
                }
            }
            
            Section("Bisher hochgeladene Bilder") {
                if let imageURLs = quest.imageURLs, !imageURLs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(imageURLs, id: \.self) { urlString in
                                if let url = URL(string: urlString) {
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
                            }
                        }
                    }
                    .frame(height: 120)
                } else {
                    Text("Keine Bilder vorhanden.")
                        .foregroundColor(.gray)
                }
            }
            
            Section("Neues Bild hinzufügen") {
                
                Button("Bild aus Fotobibliothek") {
                    showImagePicker = true
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker { selectedImage in

                        self.localSelectedImage = selectedImage
                    }
                }
                
                VStack {
                    Text("Oder hier ein Bild reinziehen:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(isDropTargeted ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        .frame(height: 100)
                        .overlay(
                            Text("Drag & Drop Zone")
                                .foregroundColor(.blue)
                        )
                        .cornerRadius(8)
                        .onDrop(
                            of: [UTType.image.identifier],
                            isTargeted: $isDropTargeted
                        ) { providers in
                            guard let provider = providers.first else { return false }
                            provider.loadItem(
                                forTypeIdentifier: UTType.image.identifier,
                                options: nil
                            ) { item, error in
                                if let error = error {
                                    errorMessage = "Fehler beim Drag & Drop: \(error.localizedDescription)"
                                    return
                                }
                                if let url = item as? URL,
                                   let data = try? Data(contentsOf: url),
                                   let droppedImage = UIImage(data: data) {
                                    // Bild nur lokal speichern
                                    DispatchQueue.main.async {
                                        self.localSelectedImage = droppedImage
                                    }
                                }
                            }
                            return true
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
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Section {
                Button("Speichern") {
                    print("SPEICHERN BEGINNT: Lokales Bild = \(String(describing: localSelectedImage))")
                    
                    if let image = localSelectedImage {
                        print("UPLOAD VORBEREITET: Bild wird hochgeladen...")
                        questLogVM.uploadImage(image, for: quest) { result in
                            switch result {
                            case .success(let url):
                                print("UPLOAD ERFOLGREICH: Bild-URL = \(url)")
                                saveQuestData()
                            case .failure(let error):
                                print("UPLOAD ERROR: \(error.localizedDescription)")
                                errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
                            }
                        }
                    } else {
                        print("KEIN LOKALES BILD: Speichere nur Quest-Daten")
                        saveQuestData()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Löschen", role: .destructive) {
                    questLogVM.deleteQuest(quest)
                    dismiss()
                }
            }
        }
        .navigationTitle("Quest bearbeiten")
        .sheet(isPresented: $showAssignCharactersSheet) {
            AssignCharactersView(quest: quest)
                .environmentObject(questLogVM)
                .environmentObject(characterVM)
                .environmentObject(userViewModel)
        }
    }
    
    private func saveQuestData() {
        let updatedQuest = Quest(
            id: quest.id,
            title: title,
            description: description,
            status: status,
            createdAt: quest.createdAt,
            userId: quest.userId,
            reward: reward.isEmpty ? nil : reward,
            creatorDisplayName: quest.creatorDisplayName,
            assignedCharacterIds: quest.assignedCharacterIds,
            imageURLs: quest.imageURLs // URLs sicherstellen
        )
        
        questLogVM.updateQuest(updatedQuest)
        dismiss()
    }
}
