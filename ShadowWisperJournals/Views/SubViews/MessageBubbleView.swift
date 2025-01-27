//
//  MessageBubbleView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 13.01.25.
// 

import SwiftUI

/// `MessageBubbleView` ist eine View-Komponente, die eine einzelne Chat-Nachricht darstellt.
/// Sie zeigt Nachrichten unterschiedlich an, je nachdem, ob die Nachricht vom Benutzer stammt oder von einem anderen Teilnehmer.
///
/// Hauptfunktionen:
/// - Darstellung von Nachrichten in "Sprechblasen"-Form.
struct MessageBubbleView: View {
    
    /// Die Nachricht, die dargestellt wird.
    let message: ChatMessage
    
    /// Gibt an, ob die Nachricht vom Benutzer stammt.
    let isMine: Bool
    
    /// Gibt an, ob die Nachricht von allen Teilnehmern gelesen wurde.
    let allHaveRead: Bool
    
    /// Gibt an, ob die Nachricht vom Benutzer gelesen wurde.
    let readByMe: Bool
    
    /// Eine Aktion, die ausgeführt wird, wenn die Nachricht erscheint (z. B. zur Markierung als gelesen).
    let onAppearAction: () -> Void
    
    var body: some View {
        Group {
            if isMine {
                // MARK: - Eigene Nachrichten
                HStack {
                    Spacer() // Drückt die Nachricht nach rechts
                    VStack(alignment: .trailing) {
                        // Nachrichtentext
                        Text(message.text)
                            .padding(8)
                            .background(Color.blue.opacity(0.2)) // Blaue Blase für eigene Nachrichten
                            .cornerRadius(8)
                        
                        // Lesestatus
                        if allHaveRead {
                            Text("Gelesen von allen")
                                .font(.caption2) // Kleine Schriftart für Zusatzinfo
                                .foregroundColor(.gray)
                        } else if readByMe {
                            Text("Gelesen von dir")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            } else {
                // MARK: - Nachrichten anderer Teilnehmer
                VStack(alignment: .leading) {
                    // Nachrichtentext
                    Text(message.text)
                        .padding(8)
                        .background(Color.green.opacity(0.2)) // Grüne Blase für empfangene Nachrichten
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Nachricht links ausrichten
                .onAppear {
                    onAppearAction() // Aktion ausführen, wenn Nachricht angezeigt wird
                }
            }
        }
    }
}
