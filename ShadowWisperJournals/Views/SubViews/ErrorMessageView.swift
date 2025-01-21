//
//  ErrorMessageView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct ErrorMessageView: View {
    var errorMessage: String
    
    var body: some View {
        Text(errorMessage)
            .foregroundColor(.red)
            .font(.system(size: 16))
            .padding()
    }
}
