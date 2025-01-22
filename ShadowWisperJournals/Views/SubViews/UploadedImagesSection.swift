//
//  UploadedImagesSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct UploadedImagesSection: View {
    @Binding var localImageURLs: [String]
    @Binding var selectedImageURL: URL?
    @Binding var showFullScreenImage: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bisher hochgeladene Bilder")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            if !localImageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(localImageURLs, id: \.self) { urlString in
                            if let url = URL(string: urlString) {
                                Button(action: {
                                    selectedImageURL = url
                                    showFullScreenImage = true
                                }) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                        case .failure:
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
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(height: 120)
            } else {
                Text("Keine Bilder vorhanden.")
                    .foregroundColor(.gray)
                    .font(.custom("SmoochSans-Bold", size: 18))
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
