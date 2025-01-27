//
//  QuestDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 05.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

/**
 `QuestDetailView` ermöglicht das Bearbeiten einer bestehenden Quest.
 Nutzer:innen können Titel, Beschreibung, Status, Belohnung, persönliche Notizen,
 Standort sowie Bilder verändern oder löschen. Zudem können weitere Charaktere
 der Quest zugewiesen werden.
 
 **Funktionen**:
 - Anzeigen und Bearbeiten der Quest-Informationen
 - Hochladen neuer Bilder (mit Fortschrittsanzeige)
 - Löschen der Quest
 - Persönliche Notizen hinzufügen
 - Anzeige eines Toasts zur Bestätigung von Änderungen
 - Verhinderung von parallelen Uploads (`isUploading`)
 */
struct QuestDetailView: View {
    
    // MARK: - Environment
    
    /// Ermöglicht das Schließen (Dismiss) der aktuellen View.
    @Environment(\.dismiss) var dismiss
    
    /// Liefert Informationen zum aktuellen Nutzer (z. B. `userId`).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    /// Das Character-ViewModel zum Verwalten aller Charakterdaten (z. B. bei der Zuweisung).
    @EnvironmentObject var characterVM: CharacterViewModel
    
    // MARK: - ObservedObject
    
    /// ViewModel für das Verwalten (Lesen, Bearbeiten, Löschen) von Quests.
    @ObservedObject var questLogVM: QuestLogViewModel
    
    // MARK: - Eingabedaten
    
    /// Die zu bearbeitende Quest.
    var quest: Quest
    
    // MARK: - State Variablen (Form Felder)
    
    /// Titel der Quest.
    @State private var title: String
    
    /// Beschreibung (Fließtext).
    @State private var description: String
    
    /// Status der Quest (z. B. "aktiv" oder "abgeschlossen").
    @State private var status: String
    
    /// Belohnung der Quest (optional).
    @State private var reward: String
    
    // MARK: - Sheet / Picker-States
    
    /// Steuert, ob das Sheet zum Zuweisen weiterer Charaktere angezeigt wird.
    @State private var showAssignCharactersSheet = false
    
    /// Steuert die Anzeige des Image-Pickers zum Hochladen eines neuen Bildes.
    @State private var showImagePicker = false
    
    /// Lokal ausgewähltes Bild, das hochgeladen werden soll.
    @State private var localSelectedImage: UIImage?
    
    /// Fehlermeldung bei fehlgeschlagenem Upload oder ungültiger Eingabe.
    @State private var errorMessage: String?
    
    // MARK: - Standort, Notizen, Bilder
    
    /// Lokaler String für den Standort (z. B. Adresse).
    @State private var localLocationString: String
    
    /// Persönliche Notizen zur Quest, nur für den/die Nutzer:in selbst.
    @State private var personalNotes: String
    
    /// Lokale Liste der URLs von hochgeladenen Bildern.
    @State private var localImageURLs: [String] = []
    
    // MARK: - Bild-Vollbildanzeige
    
    /// Speichert die aktuell ausgewählte Bild-URL, um sie in einer Fullscreen-Ansicht zu zeigen.
    @State private var selectedImageURL: URL?
    
    /// Steuert, ob ein Bild in voller Größe angezeigt wird.
    @State private var showFullScreenImage: Bool = false
    
    // MARK: - UI Feedback
    
    /// Steuert, ob ein Toast angezeigt wird (z. B. nach erfolgreichem Speichern).
    @State private var showToast: Bool = false
    
    /// Verhindert parallele Uploads; zeigt bei `true` ein Lade-Overlay.
    @State private var isUploading: Bool = false
    
    // MARK: - Initializer
    
    /**
     Erstellt eine Instanz von `QuestDetailView` und initialisiert die State-Variablen
     anhand der übergebenen `Quest`.
     
     - Parameter quest: Die zu bearbeitende Quest.
     - Parameter questLogVM: Das ViewModel zum Verwalten der Quest-Daten.
     */
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
    
    // MARK: - Body
    
    /**
     Das View-Layout wird mit einem ZStack und einer `NavigationStack`-basierten
     ScrollView realisiert. Mehrere Subviews strukturieren den Inhalt (z. B.
     `QuestDetailsSection`, `NotesSection`, `AssignedCharactersSection` usw.).
     */
    var body: some View {
        ZStack {
            // Hintergrund (z. B. animierter Farbverlauf)
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            // Hauptinhalt
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // MARK: Quest-Details (Titel, Beschreibung, Status, Belohnung)
                        QuestDetailsSection(
                            title: $title,
                            description: $description,
                            status: $status,
                            reward: $reward
                        )
                        
                        // MARK: Persönliche Notizen
                        NotesSection(personalNotes: $personalNotes)
                        
                        // MARK: Ersteller-Info
                        if let creatorName = quest.creatorDisplayName {
                            CreatedBySection(creatorName: creatorName)
                        }
                        
                        // MARK: Zugeordnete Charaktere
                        AssignedCharactersSection(
                            showAssignCharactersSheet: $showAssignCharactersSheet,
                            quest: quest
                        )
                        
                        // MARK: Bereits hochgeladene Bilder
                        UploadedImagesSection(
                            localImageURLs: $localImageURLs,
                            selectedImageURL: $selectedImageURL,
                            showFullScreenImage: $showFullScreenImage
                        )
                        
                        // MARK: Neues Bild hochladen
                        AddNewImageSection(
                            showImagePicker: $showImagePicker,
                            localSelectedImage: $localSelectedImage
                        )
                        
                        // MARK: Standort
                        LocationSection(localLocationString: $localLocationString)
                        
                        // MARK: Fehlermeldung
                        if let errorMessage = errorMessage {
                            ErrorMessageView(errorMessage: errorMessage)
                        }
                        
                        // MARK: Aktionen (Speichern / Löschen)
                        ActionsSection(
                            saveAction: saveQuestData,
                            deleteAction: deleteQuest
                        )
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
                // >>> NEU HINZUGEFÜGT <<<
                // Hier wird das Sheet tatsächlich angezeigt, wenn showAssignCharactersSheet true ist.
                .sheet(isPresented: $showAssignCharactersSheet) {
                    AssignCharactersSheetView(quest: quest)
                        .environmentObject(questLogVM)    // >>> NEU HINZUGEFÜGT <<<
                        .environmentObject(characterVM)   // >>> NEU HINZUGEFÜGT <<<
                        .environmentObject(userViewModel) // >>> NEU HINZUGEFÜGT <<<
                }
            }
            
            // MARK: Toast bei Erfolg
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
            
            // MARK: Lade-Overlay (Upload in Progress)
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
    
    // MARK: - Funktionen
    
    /**
     Startet den Speichervorgang für die Quest.
     - Verhindert parallele Uploads (prüft `isUploading`).
     - Prüft, ob Titel und Beschreibung vorhanden sind.
     - Falls ein neues Bild ausgewählt wurde, wird es zuerst hochgeladen.
     - Aktualisiert anschließend die Quest-Daten (Titel, Status, etc.).
     */
    private func saveQuestData() {
        // Parallel-Uploads verhindern
        guard !isUploading else {
            return
        }
        
        // Validierung
        guard !title.isEmpty, !description.isEmpty else {
            errorMessage = "Titel und Beschreibung dürfen nicht leer sein."
            return
        }
        
        isUploading = true
        
        // Prüfen, ob ein neues lokales Bild vorhanden ist
        if let image = localSelectedImage {
            questLogVM.uploadImage(image, for: quest) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let uploadedURLString):
                        // Bei Erfolg, Bild-URL in localImageURLs aufnehmen, falls noch nicht vorhanden
                        if !self.localImageURLs.contains(uploadedURLString) {
                            self.localImageURLs.append(uploadedURLString)
                        }
                        // Quest-Daten aktualisieren
                        updateQuestData(with: uploadedURLString)
                        
                        // Toast anzeigen und nach 2 Sek. wieder ausblenden
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                        
                        isUploading = false
                        dismiss()
                        
                    case .failure(let error):
                        // Fehlermeldung, kein Dismiss
                        self.errorMessage = "Fehler beim Hochladen des Bildes: \(error.localizedDescription)"
                        isUploading = false
                    }
                }
            }
        } else {
            // Kein Bild -> nur Daten aktualisieren
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
    
    /**
     Erstellt eine aktualisierte Kopie der Quest und ruft `questLogVM.updateQuest()` auf.
     
     - Parameter newImageURL: Falls ein neues Bild hochgeladen wurde, kann hier die URL
     übergeben werden (ggf. bereits in `localImageURLs` enthalten).
     */
    private func updateQuestData(with newImageURL: String?) {
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
        
        // Im Quest-ViewModel aktualisieren
        questLogVM.updateQuest(updatedQuest)
    }
    
    /**
     Löscht die aktuelle Quest (über `questLogVM.deleteQuest`) und schließt die View.
     */
    private func deleteQuest() {
        questLogVM.deleteQuest(quest)
        dismiss()
    }
}
