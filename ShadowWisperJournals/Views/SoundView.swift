//
//  SoundView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
// test


import SwiftUI
import UniformTypeIdentifiers

struct SoundView: View {
    @StateObject private var viewModel = SoundViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Soundbereich")
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                }
                
                Section(header: Text("Suche")) {
                    HStack {
                        TextField("Nach Schlagworten suchen...", text: $viewModel.searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        
                        Button("Suchen") {
                            Task {
                                await viewModel.searchOnYouTube()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.searchQuery.isEmpty)
                    }
                    
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Suche läuft...")
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                if !viewModel.searchResults.isEmpty {
                    Section(header: Text("Suchergebnisse")) {
                        ForEach(viewModel.searchResults) { item in
                            Button {
                                viewModel.videoID = item.idInfo.videoId
                            } label: {
                                HStack(alignment: .top, spacing: 10) {
                                    AsyncImage(url: URL(string: item.snippet.thumbnails.defaultThumbnail.url)) { image in
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
                            .swipeActions(edge: .trailing) {
                                Button {
                                    viewModel.addToFavorites(videoId: item.idInfo.videoId)
                                } label: {
                                    Label("Favorit", systemImage: "heart.fill")
                                }
                                .tint(.pink)
                            }
                        }
                    }
                }
                
                Section(header: Text("Aktuelles Video")) {
                    YouTubePlayerView(videoID: viewModel.videoID)
                        .frame(height: 200)
                        .cornerRadius(8)
                        .padding(.vertical, 5)
                }
                
                if !viewModel.favoriteVideos.isEmpty {
                    Section(header: Text("Deine Favoriten")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.favoriteVideos, id: \.self) { favID in
                                    YouTubePlayerView(videoID: favID)
                                        .frame(width: 200, height: 150)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                Section(header: Text("Eigene Sounds")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            viewModel.showingDocumentPicker = true
                        } label: {
                            Label("Datei auswählen", systemImage: "paperclip")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.bordered)
                        
                        if viewModel.ownSounds.isEmpty {
                            Text("Noch keine eigenen Sounds hinzugefügt.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 5)
                        } else {
                            ForEach(viewModel.ownSounds, id: \.self) { soundURL in
                                Text(soundURL.lastPathComponent)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Soundbereich")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingDocumentPicker) {
                DocumentPickerView { url in
                    viewModel.addOwnSound(url: url)
                }
            }
        }
    }

    struct SoundView_Previews: PreviewProvider {
        static var previews: some View {
            SoundView()
        }
    }
}
