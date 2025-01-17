//
//  CharakteruebersichtView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
// 

import SwiftUI

struct CharakteruebersichtView: View {
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    @StateObject private var characterVM = CharacterViewModel()
    @State private var showAddCharacterSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if let userId = userViewModel.user?.id {
                    List(characterVM.characters) { character in
                        NavigationLink(
                            destination: CharacterDetailView(character: character)
                        ) {
                            HStack(spacing: 12) {
                                if let profileURL = character.profileImageURL,
                                   let url = URL(string: profileURL)
                                {
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
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(character.name)
                                        .font(.headline)
                                    Text("Erstellt am \(character.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Charakterübersicht")
                    .toolbar {
                        Button {
                            showAddCharacterSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    .sheet(isPresented: $showAddCharacterSheet) {
                        AddCharacterView(characterVM: characterVM, userId: userId)
                    }
                    .onAppear {
                        characterVM.fetchCharacters(for: userId)
                    }
                } else {
                    Text("Kein Benutzer eingeloggt")
                }
            }
        }
    }
}

#Preview {
    CharakteruebersichtView()
}
