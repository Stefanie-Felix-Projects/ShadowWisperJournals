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
    
    @State private var showToast: Bool = false // Hinzugefügt für Toast
    @State private var isUploading: Bool = false // Hinzugefügt zur Verhinderung von Mehrfachuploads
    
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
        ZStack {
            // Hintergrund mit Animation
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Quest-Details Section
                        QuestDetailsSection(title: $title, description: $description, status: $status, reward: $reward)
                        
                        // Notes Section
                        NotesSection(personalNotes: $personalNotes)
                        
                        // Created By Section
                        if let creatorName = quest.creatorDisplayName {
                            CreatedBySection(creatorName: creatorName)
                        }
                        
                        // Assigned Characters Section
                        AssignedCharactersSection(showAssignCharactersSheet: $showAssignCharactersSheet, quest: quest)
                        
                        // Uploaded Images Section
                        UploadedImagesSection(localImageURLs: $localImageURLs, selectedImageURL: $selectedImageURL, showFullScreenImage: $showFullScreenImage)
                        
                        // Add New Image Section
                        AddNewImageSection(showImagePicker: $showImagePicker, localSelectedImage: $localSelectedImage)
                        
                        // Location Section
                        LocationSection(localLocationString: $localLocationString)
                        
                        // Fehlermeldung Section
                        if let errorMessage = errorMessage {
                            ErrorMessageView(errorMessage: errorMessage)
                        }
                        
                        // Quest hinzufügen Button
                        ActionsSection(saveAction: saveQuestData, deleteAction: deleteQuest)
                    }
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Quest bearbeiten")
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
            
            // Toast Overlay direkt im äußeren ZStack platzieren
            if showToast {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Quest hinzugefügt!")
                            .font(.custom("SmoochSans-Regular", size: 16))
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
            
            // Overlay für den Upload-Status
            if isUploading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Lade hoch...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
            }
        }
    }
    
    private func saveQuestData() {
        guard !isUploading else {
            return // Verhindert Mehrfachaufrufe
        }
        
        guard !title.isEmpty, !description.isEmpty else {
            errorMessage = "Titel und Beschreibung dürfen nicht leer sein."
            return
        }
        
        isUploading = true // Setzt den Upload-Status auf wahr
        
        if let image = localSelectedImage {
            questLogVM.uploadImage(image, for: quest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let uploadedURLString):
                        // Überprüfe, ob die URL bereits in localImageURLs vorhanden ist
                        if !self.localImageURLs.contains(uploadedURLString) {
                            self.localImageURLs.append(uploadedURLString)
                        }
                        updateQuestData(with: uploadedURLString)
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                        isUploading = false
                        dismiss()
                        
                    case .failure(let error):
                        self.errorMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
                        isUploading = false
                    }
                }
            }
        } else {
            updateQuestData(with: nil)
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showToast = false
                }
            }
            isUploading = false
            dismiss()
        }
    }
    
    private func updateQuestData(with newImageURL: String?) {
        var updatedQuest = Quest(
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
        
        // Entferne die redundante Appending-Logik
        /*
        if let newURL = newImageURL {
            if !updatedQuest.imageURLs.contains(newURL) {
                updatedQuest.imageURLs?.append(newURL)
            }
        }
        */
        
        questLogVM.updateQuest(updatedQuest)
    }
    
    private func deleteQuest() {
        questLogVM.deleteQuest(quest)
        dismiss()
    }
}
