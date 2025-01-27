//
//  LargeImageView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `LargeImageView` ist eine View-Komponente, die ein Bild in voller Größe anzeigt. Sie bietet:
/// - Asynchrones Laden des Bildes von einer URL.
/// - Darstellung von Ladezustand und Fehlerfall.
/// - Eine Navigationsleiste mit einem Titel und einem "Schließen"-Button.
///
/// Hauptfunktionen:
/// - Anzeige eines Bildes in voller Größe.
/// - Integration von Lade- und Fehleranzeigen.
/// - NavigationView für die Verwaltung von Toolbars und Titelanzeige.
struct LargeImageView: View {
    
    /// Die URL des anzuzeigenden Bildes.
    let imageURL: URL
    
    /// Der Titel, der in der Navigationsleiste angezeigt wird.
    let title: String
    
    /// Zugriff auf die Umgebungsvariable, um die View zu schließen.
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            // MARK: - Asynchrones Bild
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    // Ladeanzeige, wenn das Bild geladen wird.
                    ProgressView()
                        .scaleEffect(1.5) // Vergrößerte Ladeanzeige
                case .success(let image):
                    // Erfolgreich geladenes Bild.
                    image
                        .resizable()
                        .scaledToFit() // Proportionale Skalierung
                        .background(Color.black) // Schwarzer Hintergrund für besseren Kontrast
                        .ignoresSafeArea(edges: .bottom) // Vollbilddarstellung
                case .failure:
                    // Fehleranzeige, wenn das Bild nicht geladen werden kann.
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.red) // Rote Farbe für Fehlerindikator
                @unknown default:
                    // Standardmäßig leerer View für unerwartete Fälle.
                    EmptyView()
                }
            }
            .navigationTitle(title) // Titel in der Navigationsleiste
            .navigationBarTitleDisplayMode(.inline) // Titel zentriert und kompakt
            .toolbar {
                // MARK: - Toolbar mit Schließen-Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss() // Schließt die View
                    }
                    .foregroundColor(AppColors.signalColor2) // Button-Farbe
                }
            }
        }
    }
}
