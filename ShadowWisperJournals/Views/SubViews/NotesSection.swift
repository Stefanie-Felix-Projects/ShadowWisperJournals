//
//  NotesSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct NotesSection: View {
    @Binding var personalNotes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meine Notizen")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            TextEditor(text: $personalNotes)
                .font(.system(size: 16))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .frame(minHeight: 100)
            
            Button(action: {
                UIPasteboard.general.string = personalNotes
            }) {
                Text("Notizen kopieren")
                    .font(.footnote)
                    .foregroundColor(AppColors.signalColor2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
