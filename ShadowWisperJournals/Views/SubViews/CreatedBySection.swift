//
//  CreatedBySection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct CreatedBySection: View {
    var creatorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Erstellt von")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            Text(creatorName)
                .font(.custom("SmoochSans-Regular", size: 20))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
