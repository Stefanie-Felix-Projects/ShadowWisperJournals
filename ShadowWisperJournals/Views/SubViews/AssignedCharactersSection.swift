//
//  AssignedCharactersSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct AssignedCharactersSection: View {
    @Binding var showAssignCharactersSheet: Bool
    var quest: Quest
    @EnvironmentObject var characterVM: CharacterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Zugewiesene Charaktere")
                    .font(.custom("SmoochSans-Bold", size: 22))
                    .foregroundColor(AppColors.signalColor4)
                Spacer()
                Button(action: {
                    showAssignCharactersSheet = true
                }) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(AppColors.signalColor2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if let assignedCharacterIds = quest.assignedCharacterIds,
               !assignedCharacterIds.isEmpty {
                ForEach(assignedCharacterIds, id: \.self) { charId in
                    if let foundChar = characterVM.characters.first(where: { $0.id == charId }) {
                        HStack {
                            if let profileImageURL = foundChar.profileImageURL,
                               let url = URL(string: profileImageURL) {
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
                                Text(foundChar.name)
                                    .font(.custom("SmoochSans-Bold", size: 20))
                                    .foregroundColor(.white)
                                if let metaType = foundChar.metaType {
                                    Text(metaType)
                                        .font(.custom("SmoochSans-Regular", size: 18))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Text("Unbekannter Charakter (ID: \(charId))")
                            .foregroundColor(.gray)
                            .font(.custom("SmoochSans-Regular", size: 18))
                    }
                }
            } else {
                Text("Keine Charaktere zugewiesen.")
                    .foregroundColor(.gray)
                    .font(.custom("SmoochSans-Regular", size: 18))
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
