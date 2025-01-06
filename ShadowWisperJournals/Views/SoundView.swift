//
//  SoundView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 04.01.25.
//

import SwiftUI
import WebKit

struct SoundView: View {

    @State private var videoID: String = "T2QZpy07j4s"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("Soundbereich mit YouTube-Integration")
                    .font(.title)
                    .padding(.top, 16)
                
                HStack {
                    TextField("Video-ID", text: $videoID)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                    
                    Button("Abspielen") {
                        hideKeyboard()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                YouTubePlayerView(videoID: videoID)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                Text("Weitere Sound-Funktionen hier integrieren...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Soundbereich")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

#Preview {
    SoundView()
}
