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
        ZStack {
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        QuestDetailsSection(title: $title, description: $description, status: $status, reward: $reward)
                        NotesSection(personalNotes: $personalNotes)
                        if let creatorName = quest.creatorDisplayName {
                            CreatedBySection(creatorName: creatorName)
                        }
                        AssignedCharactersSection(showAssignCharactersSheet: $showAssignCharactersSheet, quest: quest)
                        UploadedImagesSection(localImageURLs: $localImageURLs, selectedImageURL: $selectedImageURL, showFullScreenImage: $showFullScreenImage)
                        AddNewImageSection(showImagePicker: $showImagePicker, localSelectedImage: $localSelectedImage)
                        LocationSection(localLocationString: $localLocationString)
                        if let errorMessage = errorMessage {
                            ErrorMessageView(errorMessage: errorMessage)
                        }
                        ActionsSection(saveAction: saveQuestData, deleteAction: deleteQuest)
                    }
                    .padding(.horizontal, 16)
                }
                .navigationTitle("Quest bearbeiten")
                .sheet(isPresented: $showAssignCharactersSheet) {
                    AssignCharactersSheetView(quest: quest)
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
            .background(Color.clear)
        }
    }
    
    private func saveQuestData() {
        if let image = localSelectedImage {
            questLogVM.uploadImage(image, for: quest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let uploadedURLString):
                        self.localImageURLs.append(uploadedURLString)
                        updateQuestData(with: uploadedURLString)
                    case .failure(let error):
                        self.errorMessage = "Fehler beim Hochladen: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            updateQuestData(with: nil)
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
        
        if let newURL = newImageURL {
            updatedQuest.imageURLs?.append(newURL)
        }
        
        questLogVM.updateQuest(updatedQuest)
        dismiss()
    }
    
    private func deleteQuest() {
        questLogVM.deleteQuest(quest)
        dismiss()
    }
}
