//
//  AddNewImageSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

/// `AddNewImageSection` ist eine View-Komponente, die es dem Benutzer ermöglicht, ein Bild aus
/// der Fotobibliothek auszuwählen und eine Vorschau des ausgewählten Bildes anzuzeigen.
///
/// Hauptfunktionen:
/// - Öffnen des Bildauswahlers (Image Picker).
/// - Anzeige einer Vorschau des ausgewählten Bildes.
/// - Feedback, wenn kein Bild ausgewählt wurde.
struct AddNewImageSection: View {
    
    /// Binding-Variable, die steuert, ob der Bildauswähler angezeigt wird.
    @Binding var showImagePicker: Bool
    
    /// Binding-Variable, die das lokal ausgewählte Bild speichert.
    @Binding var localSelectedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Titel
            Text("Neues Bild hinzufügen")
                .font(.custom("SmoochSans-Bold", size: 22)) // Benutzerdefinierte Schriftart
                .foregroundColor(AppColors.signalColor4) // Titel-Farbe
            
            // MARK: - Button: Bild aus Fotobibliothek auswählen
            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo") // Symbol für Fotobibliothek
                        .foregroundColor(.black)
                    Text("Bild aus Fotobibliothek")
                        .font(.custom("SmoochSans-Bold", size: 22))
                        .foregroundColor(.black)
                }
                .padding() // Innenabstand
                .frame(maxWidth: .infinity) // Maximale Breite
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.signalColor1, // Startfarbe
                            AppColors.signalColor5  // Endfarbe
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8) // Abgerundete Ecken
                .shadow(
                    color: AppColors.signalColor1.opacity(0.8), // Schattenfarbe mit Transparenz
                    radius: 10, // Schattenradius
                    x: 0,
                    y: 5 // Vertikale Schattenverschiebung
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { selectedImage in
                    self.localSelectedImage = selectedImage
                }
            }
            
            // MARK: - Vorschau des ausgewählten Bildes
            if let localImage = localSelectedImage {
                // Textanzeige über der Bildvorschau
                Text("Vorschau (noch nicht hochgeladen):")
                    .font(.custom("SmoochSans-Regular", size: 16))
                    .foregroundColor(.secondary)
                
                // Anzeige des ausgewählten Bildes
                Image(uiImage: localImage)
                    .resizable() // Bildgröße anpassbar machen
                    .scaledToFit() // Bild proportional anpassen
                    .frame(height: 120) // Maximale Höhe
                    .cornerRadius(8) // Abgerundete Ecken
            } else {
                // Anzeige, wenn kein Bild ausgewählt wurde
                Text("Kein lokales Bild ausgewählt")
                    .font(.custom("SmoochSans-Regular", size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding() // Innenabstand um die gesamte View
        .background(Color.black.opacity(0.3)) // Hintergrundfarbe mit Transparenz
        .cornerRadius(12) // Abgerundete Ecken für die gesamte Sektion
    }
}
