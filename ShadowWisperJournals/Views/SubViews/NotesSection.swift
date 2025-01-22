//
//  NotesSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct NotesSection: View {
    @Binding var personalNotes: String
    @State private var showToast: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meine Notizen")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            TextEditor(text: $personalNotes)
                .font(.custom("SmoochSans-Regular", size: 20))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .frame(minHeight: 100)
            
            Button(action: {
                UIPasteboard.general.string = personalNotes
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showToast = false
                    }
                }
            }) {
                Text("Notizen kopieren")
                    .font(.custom("SmoochSans-Regular", size: 18))
                    .foregroundColor(AppColors.signalColor2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            VStack {
                if showToast {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Notizen kopiert!")
                            .font(.custom("SmoochSans-Regular", size: 16))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showToast)
                }
            }
        )
    }
}
