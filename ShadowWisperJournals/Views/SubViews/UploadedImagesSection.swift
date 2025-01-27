//
//  UploadedImagesSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `UploadedImagesSection` ist eine View-Komponente, die eine Sammlung von hochgeladenen Bildern darstellt.
/// Benutzer können die Bilder in einer horizontalen Liste anzeigen und ein Bild auswählen, um es in einer
/// Vollbildansicht zu öffnen.
///
/// Hauptfunktionen:
/// - Horizontale Anzeige hochgeladener Bilder.
/// - Dynamische Lade- und Fehleranzeige für Bilder.
/// - Möglichkeit, ein Bild auszuwählen und in einer Vollbildansicht anzuzeigen.
struct UploadedImagesSection: View {
    
    /// Eine Binding-Variable, die die URLs der hochgeladenen Bilder speichert.
    @Binding var localImageURLs: [String]
    
    /// Eine Binding-Variable, die die URL des aktuell ausgewählten Bildes speichert.
    @Binding var selectedImageURL: URL?
    
    /// Eine Binding-Variable, die steuert, ob die Vollbildansicht eines Bildes angezeigt werden soll.
    @Binding var showFullScreenImage: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Überschrift
            /// Titel der Sektion "Bisher hochgeladene Bilder".
            Text("Bisher hochgeladene Bilder")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Titel-Farbe
            
            // MARK: - Bilderliste
            if !localImageURLs.isEmpty {
                // ScrollView für horizontale Bildanzeige
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(localImageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                // Button zum Öffnen des ausgewählten Bildes in der Vollbildansicht
                                Button(action: {
                                    selectedImageURL = url
                                    showFullScreenImage = true
                                }) {
                                    // Asynchrones Laden des Bildes
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            // Ladeanzeige
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        case .success(let image):
                                            // Erfolgreich geladenes Bild
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped() // Beschneidet überstehende Inhalte
                                                .cornerRadius(8) // Abgerundete Ecken
                                        case .failure:
                                            // Platzhalter für fehlgeschlagene Bilder
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
                                .buttonStyle(.plain) // Entfernt Standard-Button-Stile
                            }
                        }
                    }
                }
                .frame(height: 120) // Höhe der ScrollView
            } else {
                // Anzeige, wenn keine Bilder vorhanden sind
                Text("Keine Bilder vorhanden.")
                    .foregroundColor(.gray)
                    .font(.custom("SmoochSans-Bold", size: 18)) // Benutzerdefinierte Schriftart
            }
        }
        .padding() // Innenabstand um die gesamte Sektion
        .background(Color.black.opacity(0.3)) // Halbtransparenter Hintergrund
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
