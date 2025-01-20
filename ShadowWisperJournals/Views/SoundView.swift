//
//  SoundView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SoundView: View {
    @StateObject private var viewModel = SoundViewModel()
    @State private var isSearchResultsExpanded: Bool = false
    
    var body: some View {
        ZStack {
            AnimatedBackgroundView(colors: AppColors.gradientColors)
                .ignoresSafeArea()
            
            NavigationStack {
                List {
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
                        Section {
                            HStack {
                                Text("Suchergebnisse")
                                    .font(.headline)
                                Spacer()
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
                                    Button {
                                        viewModel.videoID = item.idInfo.videoId
                                    } label: {
                                        HStack(alignment: .top, spacing: 10) {
                                            AsyncImage(url: URL(string: item.snippet.thumbnails.defaultThumbnail.url)) {
                                                image in
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
                                    ForEach(viewModel.favoriteVideos) { favorite in
                                        VStack {
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
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(soundURL.lastPathComponent)
                                                .padding(.vertical, 5)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(UIColor.secondarySystemBackground))
                                                .cornerRadius(6)
                                            
                                            HStack(spacing: 20) {
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
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Soundbereich")
                .navigationBarTitleDisplayMode(.inline)
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

struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView()
    }
}
