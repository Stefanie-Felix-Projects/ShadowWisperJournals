//
//  ActionsSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct ActionsSection: View {
    var saveAction: () -> Void
    var deleteAction: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: saveAction) {
                Text("Speichern")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
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
            
            Button(action: deleteAction) {
                Text("Löschen")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppColors.signalColor3,
                                AppColors.signalColor4
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .shadow(
                        color: AppColors.signalColor3.opacity(0.8),
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}
