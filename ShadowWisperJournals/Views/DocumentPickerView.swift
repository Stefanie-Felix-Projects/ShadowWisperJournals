//
//  DocumentPickerView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    
    let onPicked: (URL) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        let onPicked: (URL) -> Void
        
        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController,
                            didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPicked(url)
        }
    }
}

struct DocumentPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPickerView { _ in }
    }
}
