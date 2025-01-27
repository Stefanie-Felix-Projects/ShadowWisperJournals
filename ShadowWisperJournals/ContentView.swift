//
//  ContentView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 02.01.25.
//

import SwiftUI

/**
 `ContentView` dient als eine simple Beispielansicht, in der ein eingeloggter Nutzer
 begrüßt wird und sich abmelden kann.
 
 **Funktionen**:
 - Zeigt den Namen des/der Nutzers:in an (über `userViewModel.displayName`).
 - Bietet einen "Abmelden"-Button, um den Logout-Prozess anzustoßen.
 - Zeigt einen kurzen Platzhaltertext (z. B. für zukünftige Inhalte).
 
 **Hinweis**:
 - Diese View kann als einfache Hauptübersicht genutzt werden oder als Demo für
 die Funktionsweise von `userViewModel`. In einer größeren App würde man hier
 wahrscheinlich weitere Navigationsmöglichkeiten oder Inhalte bereitstellen.
 */
struct ContentView: View {
    
    /// Liefert Informationen zum currently eingeloggten Nutzer
    /// (z. B. `displayName`, Auth-Status).
    @EnvironmentObject var userViewModel: ShadowWisperUserViewModel
    
    // MARK: - Body
    
    /**
     Ein vertikaler Stack mit:
     1. Begrüßungstext inkl. angezeigtem Namen
     2. Button zum Logout
     3. Platzhaltertext für zukünftige App-Funktionalitäten.
     */
    var body: some View {
        VStack {
            Text("Willkommen, \(userViewModel.displayName ?? "Benutzer")!")
                .font(.largeTitle)
                .padding()
            
            Button("Abmelden") {
                userViewModel.logoutShadowWisperUser()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Text("Hier könnte das Shadowrun-Kampagnenmanagement starten...")
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
