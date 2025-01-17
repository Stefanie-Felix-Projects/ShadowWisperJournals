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
    @State private var errorMessage: String?
    
    @State private var localLocationString: String
    
    @State private var personalNotes: String
    @State private var localImageURLs: [String] = []
    
    @State private var selectedImageURL: URL?
    @State private var showFullScreenImage: Bool = false
    
    init(quest: Quest, questLogVM: QuestLogViewModel) {
        self.quest = quest
        self._questLogVM = ObservedObject(wrappedValue: questLogVM)
        
        _title = State(initialValue: quest.title)
        _description = State(initialValue: quest.description)
        _status = State(initialValue: quest.status)
        _reward = State(initialValue: quest.reward ?? "")
        _localLocationString = State(initialValue: quest.locationString ?? "")
        _personalNotes = State(initialValue: quest.personalNotes ?? "")
        
        _localImageURLs = State(initialValue: quest.imageURLs ?? [])
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
            
            Section("Meine Notizen") {
                TextEditor(text: $personalNotes)
                    .frame(minHeight: 100)
                
                Button("Notizen kopieren") {
                    UIPasteboard.general.string = personalNotes
                }
                .font(.footnote)
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
                            HStack {
                                if let profileImageURL = foundChar.profileImageURL, let url = URL(string: profileImageURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 40, height: 40)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        case .failure:
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(foundChar.name)
                                        .font(.headline)
                                    if let metaType = foundChar.metaType {
                                        Text(metaType)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
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
                if !localImageURLs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(localImageURLs, id: \.self) { urlString in
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
            }
            
            Section("Standort / Karte") {
                TextField("Standort-Adresse", text: $localLocationString)
                    .textInputAutocapitalization(.never)
                
                GoogleMapView(locationString: localLocationString)
                    .frame(height: 200)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Section {
                Button("Speichern") {
                    if let image = localSelectedImage {
                        questLogVM.uploadImage(image, for: quest) { result in
                            switch result {
                            case .success(let uploadedURLString):
                                localImageURLs.append(uploadedURLString)
                                saveQuestData()
                                
                            case .failure(let error):
                                errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
                            }
                        }
                    } else {
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
        .sheet(isPresented: $showFullScreenImage) {
            if let imageURL = selectedImageURL {
                LargeImageView(imageURL: imageURL, title: quest.title)
            }
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
            imageURLs: localImageURLs,
            locationString: localLocationString,
            personalNotes: personalNotes
        )
        
        questLogVM.updateQuest(updatedQuest)
        dismiss()
    }
}

struct LargeImageView: View {
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
