//
//  DocumentPickerView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

/**
 `DocumentPickerView` ist ein SwiftUI-Wrapper um `UIDocumentPickerViewController`.
 
 - Ziel: dem Nutzer die Möglichkeit geben, eine einzelne Audiodatei auszuwählen.
 - Verwendet `UIViewControllerRepresentable`, um den UIKit-Picker in SwiftUI einzubetten.
 - Gibt die ausgewählte Datei-URL (z.B. für .audio) über eine Callback-Funktion zurück.
 */
struct DocumentPickerView: UIViewControllerRepresentable {
    
    /// Callback, der nach Auswahl einer Datei die URL zurückgibt.
    var onPick: (URL) -> Void
    
    // MARK: - makeCoordinator
    
    /**
     Erstellt einen `Coordinator`, der als `UIDocumentPickerDelegate` fungiert.
     
     - Returns: Eine Instanz des `Coordinator`, der Delegate-Methoden behandelt.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator(self, onPick: onPick)
    }
    
    // MARK: - makeUIViewController
    
    /**
     Erstellt den `UIDocumentPickerViewController` mit den gewünschten Einstellungen
     (z.B. unterstützte Dateitypen, Mehrfachauswahl).
     
     - Parameter context: SwiftUI-spezifischer Kontext, der zusätzliche Infos enthält.
     - Returns: Konfigurierter `UIDocumentPickerViewController`.
     */
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Definiere unterstützte Dateitypen (hier: Audiodateien)
        let supportedTypes: [UTType] = [.audio]
        
        // Erstelle den Picker, hier als Kopie (damit nach Auswahl eine Kopie angelegt wird)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        
        // Setze den Coordinator als Delegate
        picker.delegate = context.coordinator
        
        // Erlaube nur eine einzelne Auswahl
        picker.allowsMultipleSelection = false
        
        return picker
    }
    
    // MARK: - updateUIViewController
    
    /**
     Aktualisiert den `UIDocumentPickerViewController`, wenn sich SwiftUI-Zustände ändern.
     Wird hier nicht weiter verwendet.
     
     - Parameter uiViewController: Der zu aktualisierende Dokumenten-Picker
     - Parameter context: SwiftUI-spezifischer Kontext
     */
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Keine Aktualisierung notwendig
    }
    
    // MARK: - Coordinator
    
    /**
     `Coordinator` kümmert sich um die `UIDocumentPickerDelegate`-Methoden und ruft den
     Callback `onPick` mit der ausgewählten URL auf.
     */
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        /// Referenz auf den übergeordneten `DocumentPickerView`.
        let parent: DocumentPickerView
        
        /// Callback, der ausgeführt wird, wenn eine Datei ausgewählt wurde.
        let onPick: (URL) -> Void
        
        /**
         Initialisiert den Coordinator mit Verweis auf das `DocumentPickerView`
         und dem Callback `onPick`.
         
         - Parameter parent: Die Instanz von `DocumentPickerView`, die diesen Coordinator erstellt.
         - Parameter onPick: Die Funktion, die aufgerufen wird, sobald eine Datei ausgewählt wird.
         */
        init(_ parent: DocumentPickerView, onPick: @escaping (URL) -> Void) {
            self.parent = parent
            self.onPick = onPick
        }
        
        /**
         Delegate-Methode, die aufgerufen wird, wenn der Nutzer eine oder mehrere Dateien ausgewählt hat.
         - Parameter controller: Der aktive `UIDocumentPickerViewController`.
         - Parameter urls: Liste der ausgewählten Dokument-URLs.
         */
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // Prüfe, ob mindestens eine URL vorhanden ist
            if let url = urls.first {
                // Rufe den Callback mit der ausgewählten URL auf
                onPick(url)
            }
        }
    }
}
