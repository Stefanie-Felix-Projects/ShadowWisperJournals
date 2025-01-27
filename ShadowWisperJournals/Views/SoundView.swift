//
//  SoundView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

/**
 `SoundView` stellt eine zentrale Ansicht für das Abspielen und Verwalten von
 Audioinhalten bereit. Nutzer:innen können:
 - Nach YouTube-Videos (z. B. Musik oder Sounds) suchen und sie direkt abspielen
 - Gefundene Videos zu Favoriten hinzufügen, abspielen und löschen
 - Eigene lokale Sound-Dateien importieren und abspielen (Pause, Stop, Loop)
 
 Die Suchergebnisse werden nach Erfolg einer YouTube-Suche in einer Liste angezeigt,
 Favoriten horizontal scrollbar, und eigene Sounds in einer vertikalen Liste.
 */
struct SoundView: View {
    
    // MARK: - StateObject
    
    /// `SoundViewModel` steuert die gesamte Logik: YouTube-Suche, Favoritenverwaltung,
    /// Audio-Abspielkontrolle und das Hinzufügen eigener Sounds.
    @StateObject private var viewModel = SoundViewModel()
    
    // MARK: - State
    
    /// Steuert, ob die Suchergebnisse in der Liste ein- oder ausgeklappt sind.
    @State private var isSearchResultsExpanded: Bool = false
    
    // MARK: - Body
    
    /**
     Die Hauptansicht besteht aus einem `ZStack` mit animiertem Farbverlauf
     und einem `NavigationStack`, in dem eine `List` verschiedene Abschnitte
     für die Suchfunktionen, Favoriten und eigene Sounds darstellt:
     
     1. **Suche** (YouTube)
     - TextField für Suchbegriffe + Button, der `viewModel.searchOnYouTube()` aufruft
     - Ladeindikator bei laufender Suche (`viewModel.isLoading`)
     
     2. **Suchergebnisse**
     - Ein- / Ausklappbar per Button (Chevron)
     - Zeigt gefundene Videos an, die ausgewählt und abgespielt werden können
     - Swipe-Action, um ein Video zu den Favoriten hinzuzufügen
     
     3. **Aktuelles Video**
     - `YouTubePlayerView` mit `viewModel.videoID`, das die derzeit
     ausgewählte YouTube-Video-ID abspielt.
     
     4. **Favoriten**
     - Horizontal scrollbare Liste der Favoriten-Videos, die abspielbar
     oder löschbar sind
     
     5. **Eigene Sounds**
     - Ermöglicht den Import lokaler Audiodateien via `DocumentPickerView`
     - Zeigt alle bereits importierten Dateien mit Play/Pause/Stop/Loop-Buttons
     */
    var body: some View {
        ZStack {
            // Hintergrund mit animiertem Farbverlauf
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                List {
                    
                    // MARK: Suche
                    Section(header: Text("Suche")) {
                        HStack {
                            TextField("Nach Schlagworten suchen...", text: $viewModel.searchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .autocapitalization(.none)
                            
                            // Button zum Starten der YouTube-Suche
                            Button("Suchen") {
                                Task {
                                    await viewModel.searchOnYouTube()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(viewModel.searchQuery.isEmpty)
                        }
                        
                        // Ladeindikator
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Suche läuft...")
                                Spacer()
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                    // MARK: Suchergebnisse
                    if !viewModel.searchResults.isEmpty {
                        Section {
                            HStack {
                                Text("Suchergebnisse")
                                    .font(.headline)
                                Spacer()
                                // Button zum Aus- oder Einklappen der Ergebnisse
                                Button {
                                    withAnimation {
                                        isSearchResultsExpanded.toggle()
                                    }
                                } label: {
                                    Image(systemName: isSearchResultsExpanded
                                          ? "chevron.down"
                                          : "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 5)
                            
                            if isSearchResultsExpanded {
                                ForEach(viewModel.searchResults) { item in
                                    // Auswahl eines Videos => Wechsle `videoID`
                                    Button {
                                        viewModel.videoID = item.idInfo.videoId
                                    } label: {
                                        HStack(alignment: .top, spacing: 10) {
                                            // Vorschaubild
                                            AsyncImage(
                                                url: URL(string: item.snippet.thumbnails.defaultThumbnail.url)
                                            ) { image in
                                                image.resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(width: 80, height: 60)
                                            .cornerRadius(8)
                                            
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(item.snippet.title)
                                                    .font(.headline)
                                                    .lineLimit(2)
                                                Text(item.snippet.description)
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    // Swipe-Action zum Hinzufügen in Favoriten
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            viewModel.addToFavorites(video: item)
                                        } label: {
                                            Label("Favorit", systemImage: "heart.fill")
                                        }
                                        .tint(.pink)
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: Aktuelles Video
                    Section(header: Text("Aktuelles Video")) {
                        YouTubePlayerView(videoID: viewModel.videoID)
                            .frame(height: 200)
                            .cornerRadius(8)
                            .padding(.vertical, 5)
                    }
                    
                    // MARK: Favoriten
                    if !viewModel.favoriteVideos.isEmpty {
                        Section(header: Text("Deine Favoriten")) {
                            // Horizontal scrollbare Liste
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(viewModel.favoriteVideos) { favorite in
                                        VStack {
                                            // Abspielen eines Favoriten
                                            Button {
                                                viewModel.playFavoriteVideo(videoId: favorite.id)
                                            } label: {
                                                VStack {
                                                    YouTubePlayerView(videoID: favorite.id)
                                                        .frame(width: 200, height: 150)
                                                        .cornerRadius(8)
                                                    Text(favorite.title)
                                                        .font(.footnote)
                                                        .foregroundColor(.primary)
                                                        .lineLimit(1)
                                                        .truncationMode(.tail)
                                                        .frame(maxWidth: 180)
                                                        .multilineTextAlignment(.center)
                                                }
                                            }
                                            // Löschen eines Favoriten
                                            Button(role: .destructive) {
                                                viewModel.removeFromFavorites(videoId: favorite.id)
                                            } label: {
                                                Label("Löschen", systemImage: "trash")
                                                    .font(.caption)
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    
                    // MARK: Eigene Sounds
                    Section(header: Text("Eigene Sounds")) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Button zum Öffnen des DocumentPickers
                            Button {
                                viewModel.showingDocumentPicker = true
                            } label: {
                                Label("Datei auswählen", systemImage: "paperclip")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(.bordered)
                            
                            // Liste der eigenen Sounds
                            if viewModel.ownSounds.isEmpty {
                                Text("Noch keine eigenen Sounds hinzugefügt.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 5)
                            } else {
                                ForEach(viewModel.ownSounds, id: \.self) { soundURL in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(soundURL.lastPathComponent)
                                                .padding(.vertical, 5)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(UIColor.secondarySystemBackground))
                                                .cornerRadius(6)
                                            
                                            HStack(spacing: 20) {
                                                // Abspiel-Steuerung
                                                Button {
                                                    viewModel.playOwnSound(url: soundURL)
                                                } label: {
                                                    Image(systemName: "play.circle")
                                                        .font(.title2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Button {
                                                    viewModel.pauseOwnSound(url: soundURL)
                                                } label: {
                                                    Image(systemName: "pause.circle")
                                                        .font(.title2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Button {
                                                    viewModel.stopOwnSound(url: soundURL)
                                                } label: {
                                                    Image(systemName: "stop.circle")
                                                        .font(.title2)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Button {
                                                    viewModel.toggleLoopOwnSound(url: soundURL)
                                                } label: {
                                                    Image(systemName: viewModel.loopStates[soundURL] == true
                                                          ? "repeat.circle.fill"
                                                          : "repeat.circle")
                                                    .font(.title2)
                                                    .foregroundColor(viewModel.loopStates[soundURL] == true
                                                                     ? .blue
                                                                     : .primary)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                            }
                        }
                    }
                }
                // Style und Hintergrund der Liste
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(InsetGroupedListStyle())
                
                // Navigation Title
                .navigationTitle("Soundbereich")
                .navigationBarTitleDisplayMode(.inline)
                
                // MARK: Dokumenten-Picker Sheet
                .sheet(isPresented: $viewModel.showingDocumentPicker) {
                    DocumentPickerView { url in
                        viewModel.addOwnSound(url: url)
                    }
                }
            }
            .background(Color.clear)
        }
    }
}

// MARK: - Preview
struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
    }
}
