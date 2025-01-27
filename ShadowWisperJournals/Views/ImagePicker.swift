//
//  ImagePicker.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 09.01.25.
//

import SwiftUI
import PhotosUI

/**
 `ImagePicker` ist ein SwiftUI-Wrapper um den UIKit-`UIImagePickerController`.
 
 Er ermöglicht das Auswählen eines Bildes aus der Foto-Bibliothek und gibt
 das ausgewählte `UIImage` über den Callback `onImagePicked` zurück.
 
 - Verwendung:
 ```swift
 ImagePicker { selectedImage in
 // Handle das ausgewählte Bild
 }
 ```
 
 - Wichtig:
 - Stelle sicher, dass du in deiner Info.plist die notwendigen Berechtigungen
 für den Fotozugriff gesetzt hast (z. B. `NSPhotoLibraryUsageDescription`).
 */
struct ImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Environment
    
    /// Ermöglicht das Schließen (Dismiss) des angezeigten Pickers.
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Input/Callback
    
    /**
     Callback, der das ausgewählte Bild (`UIImage`) zurückgibt,
     sobald der Nutzer den Auswahlprozess abgeschlossen hat.
     */
    let onImagePicked: (UIImage) -> Void
    
    // MARK: - UIViewControllerRepresentable Methods
    
    /**
     Erzeugt und konfiguriert den `UIImagePickerController`.
     
     - Parameter context: SwiftUI-spezifischer Kontext, der Informationen über die Umgebung enthält.
     - Returns: Eine Instanz von `UIImagePickerController` mit Fotobibliothek als Quelle.
     */
    func makeUIViewController(context: Context) -> UIImagePickerController {
        // Erstelle eine Instanz des Bild-Pickers
        let picker = UIImagePickerController()
        
        // Setze den Coordinator als Delegate
        picker.delegate = context.coordinator
        
        // Ermöglicht nur nicht-bearbeitete Bildauswahl
        picker.allowsEditing = false
        
        // Stelle die Foto-Bibliothek als Quelle ein
        picker.sourceType = .photoLibrary
        
        return picker
    }
    
    /**
     Aktualisiert den existierenden `UIImagePickerController`, wenn SwiftUI-States sich ändern.
     In diesem Fall wird nichts aktualisiert, da keine dynamischen Änderungen notwendig sind.
     
     - Parameter uiViewController: Der bestehende `UIImagePickerController`.
     - Parameter context: SwiftUI-spezifischer Kontext.
     */
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Keine Aktualisierung notwendig
    }
    
    /**
     Erstellt den `Coordinator`, der als Delegate für den `UIImagePickerController` fungiert.
     
     - Returns: Eine Instanz des `Coordinator`.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    /**
     `Coordinator` verwaltet die Delegate-Methoden des `UIImagePickerController`.
     Er leitet die Bildauswahl zurück an den `ImagePicker` über `onImagePicked`.
     */
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        /// Referenz auf die übergeordnete `ImagePicker`-Instanz
        let parent: ImagePicker
        
        /**
         Initialisiert den `Coordinator` mit Verweis auf die `ImagePicker`-Struktur.
         
         - Parameter parent: Die Instanz von `ImagePicker`, die diesen Coordinator erzeugt hat.
         */
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        /**
         Wird aufgerufen, wenn der Nutzer ein Bild ausgewählt hat.
         Extrahiert das `UIImage` aus `info` und ruft den Callback `onImagePicked` auf.
         
         - Parameter picker: Der aktuelle `UIImagePickerController`.
         - Parameter info: Ein Dictionary mit Informationen über das ausgewählte Medium.
         */
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            // Versuche, das originale Bild zu extrahieren
            if let image = info[.originalImage] as? UIImage {
                // Rufe den Callback mit dem ausgewählten Bild auf
                parent.onImagePicked(image)
            }
            // Schließe den Picker
            parent.dismiss()
        }
        
        /**
         Wird aufgerufen, wenn der Nutzer den Picker ohne Auswahl abbricht.
         
         - Parameter picker: Der aktuelle `UIImagePickerController`.
         */
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Schließe den Picker, ohne ein Bild zurückzugeben
            parent.dismiss()
        }
    }
}
