//
//  CharakteruebersichtView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI

/**
 `CharakteruebersichtView` zeigt alle Charaktere eines eingeloggten Nutzers in einer Liste.
 
 - Über die `characterVM.characters`-Liste werden Einträge dynamisch angezeigt.
 - Durch Auswahl eines Charakters gelangt man in die Detail-Ansicht (`CharacterDetailView`).
 - Über das Plus-Symbol (`.toolbar`) kann ein neuer Charakter angelegt werden (öffnet `AddCharacterView` in einem Sheet).
 
 **Voraussetzungen**:
 - Ein Benutzer muss eingeloggt sein (über `userViewModel.user?.id`).
 - `CharacterViewModel` verwaltet das Laden und Speichern der Charaktere.
 */
struct CharakteruebersichtView: View {
    
    // MARK: - Environment & ObservedObject
    
    /// `userViewModel` liefert Informationen zum aktuell eingeloggten Benutzer (z.B. `userId`).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    /// Das ViewModel für Charaktere, über das die Daten geladen und verwaltet werden.
    @StateObject private var characterVM = CharacterViewModel()
    
    // MARK: - State
    
    /// Steuert, ob das Sheet zum Hinzufügen eines neuen Charakters angezeigt wird.
    @State private var showAddCharacterSheet = false
    
    // MARK: - Body
    
    /**
     Der `NavigationStack` dient als übergeordnete Navigationsebene. Im Inneren
     wird ein animierter Hintergrund eingefügt und eine Liste aller vorhandenen
     Charaktere dargestellt.
     */
    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund mit Farbverlauf
                AnimatedBackgroundView(colors: AppColors.gradientColors)
                    .ignoresSafeArea()
                
                VStack {
                    // Prüfen, ob ein Benutzer eingeloggt ist
                    if let userId = userViewModel.user?.id {
                        
                        // Liste aller Charaktere aus dem ViewModel
                        List(characterVM.characters) { character in
                            NavigationLink(
                                destination: CharacterDetailView(character: character)
                            ) {
                                HStack(spacing: 12) {
                                    // Profilbild / Placeholder
                                    if let profileURL = character.profileImageURL,
                                       let url = URL(string: profileURL) {
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
                                    
                                    // Kurze Infos: Name & Erstellungsdatum
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
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .navigationTitle("Charakterübersicht")
                        // Toolbar mit "+"-Button zum Hinzufügen eines neuen Charakters
                        .toolbar {
                            Button {
                                showAddCharacterSheet = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        // Sheet zum Hinzufügen eines neuen Charakters
                        .sheet(isPresented: $showAddCharacterSheet) {
                            ZStack {
                                AnimatedBackgroundView(colors: AppColors.gradientColors)
                                    .ignoresSafeArea()
                                
                                AddCharacterView(characterVM: characterVM, userId: userId)
                                    .background(Color.clear)
                            }
                            .presentationBackground(.clear)
                        }
                        // Lädt die Charaktere für den aktuellen Nutzer, sobald die View erscheint
                        .onAppear {
                            characterVM.fetchCharacters(for: userId)
                        }
                    } else {
                        // Fallback, falls kein Nutzer eingeloggt ist
                        Text("Kein Benutzer eingeloggt")
                    }
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
    }
}
