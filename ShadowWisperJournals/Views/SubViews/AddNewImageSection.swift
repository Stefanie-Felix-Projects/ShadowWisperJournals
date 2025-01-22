//
//  AddNewImageSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct AddNewImageSection: View {
    @Binding var showImagePicker: Bool
    @Binding var localSelectedImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Neues Bild hinzufügen")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            Button(action: {
                showImagePicker = true
            }) {
                HStack {
                    Image(systemName: "photo")
                        .foregroundColor(.black)
                    Text("Bild aus Fotobibliothek")
                        .font(.custom("SmoochSans-Bold", size: 22))
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppColors.signalColor1,
                            AppColors.signalColor5
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
                .shadow(
                    color: AppColors.signalColor1.opacity(0.8),
                    radius: 10,
                    x: 0,
                    y: 5
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker { selectedImage in
                    self.localSelectedImage = selectedImage
                }
            }
            
            if let localImage = localSelectedImage {
                Text("Vorschau (noch nicht hochgeladen):")
                    .font(.custom("SmoochSans-Regular", size: 16))
                    .foregroundColor(.secondary)
                
                Image(uiImage: localImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
                    .cornerRadius(8)
            } else {
                Text("Kein lokales Bild ausgewählt")
                    .font(.custom("SmoochSans-Regular", size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
