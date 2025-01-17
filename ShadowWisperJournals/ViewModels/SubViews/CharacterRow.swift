//
//  CharacterRow.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 16.01.25.
//

import SwiftUI

struct CharacterRow: View {
    let character: Character
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    var body: some View {
        HStack {
            if let profileImageURL = character.profileImageURL, let url = URL(string: profileImageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text(character.name)
                if let metaType = character.metaType {
                    Text(metaType)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: toggleSelection) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}
