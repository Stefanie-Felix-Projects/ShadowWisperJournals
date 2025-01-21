//
//  QuestDetailsSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct QuestDetailsSection: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var status: String
    @Binding var reward: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quest-Details")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            TextField("Titel", text: $title)
                .font(.system(size: 18))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            TextField("Beschreibung", text: $description)
                .font(.system(size: 18))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
            
            Picker("Status", selection: $status) {
                Text("Aktiv").tag("aktiv")
                Text("Abgeschlossen").tag("abgeschlossen")
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)
            
            TextField("Belohnung", text: $reward)
                .font(.system(size: 18))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
