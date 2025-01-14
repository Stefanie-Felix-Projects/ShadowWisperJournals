//
//  MessageBubbleView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 13.01.25.
// Test

import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    let isMine: Bool
    let allHaveRead: Bool
    let readByMe: Bool
    let onAppearAction: () -> Void

    var body: some View {
        Group {
            if isMine {
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(message.text)
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)

                        if allHaveRead {
                            Text("Gelesen von allen")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        } else if readByMe {
                            Text("Gelesen von dir")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text(message.text)
                        .padding(8)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onAppear {
                    onAppearAction()
                }
            }
        }
    }
}
