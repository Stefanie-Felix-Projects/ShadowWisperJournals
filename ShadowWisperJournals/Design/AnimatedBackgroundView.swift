//
//  AnimatedBackgroundView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 20.01.25.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    @State private var startPoint = UnitPoint.topLeading
    @State private var endPoint = UnitPoint.bottomTrailing
    
    let colors: [Color]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: startPoint,
                       endPoint: endPoint)
            .animation(.linear(duration: 10).repeatForever(autoreverses: true),
                       value: startPoint)
            .onAppear {
                DispatchQueue.main.async {
                    self.startPoint = .bottomTrailing
                    self.endPoint = .topLeading
                }
            }
    }
}
