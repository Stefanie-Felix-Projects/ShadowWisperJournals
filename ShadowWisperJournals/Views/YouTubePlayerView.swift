//
//  YouTubePlayerView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI
import WebKit

/**
 `YouTubePlayerView` ist ein SwiftUI-Wrapper für `WKWebView`, der ein YouTube-Video
 via Embedded Link basierend auf einer `videoID` anzeigt.
 
 **Wichtig**: Es wird Inline-Wiedergabe (`allowsInlineMediaPlayback`) erlaubt,
 damit das Video nicht automatisch in den Vollbildmodus wechselt.
 */
struct YouTubePlayerView: UIViewRepresentable {
    
    /// Die eindeutige ID des YouTube-Videos (z. B. "dQw4w9WgXcQ").
    let videoID: String
    
    // MARK: - makeUIView
    
    /**
     Erstellt den `WKWebView` mit spezieller Konfiguration für die Inline-Medienwiedergabe.
     
     - Parameter context: Der SwiftUI-Context, der zusätzliche Infos liefert.
     - Returns: Ein konfigurierter `WKWebView` zum Einbetten in SwiftUI.
     */
    func makeUIView(context: Context) -> WKWebView {
        // Konfiguration für den WebView
        let configuration = WKWebViewConfiguration()
        
        // Erlaubt das Abspielen von Videos ohne Vollbildmodus
        configuration.allowsInlineMediaPlayback = true
        
        // Ab iOS 10 können Medien ohne User-Aktion wiedergegeben werden
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        } else {
            // Fallback für ältere iOS-Versionen
            configuration.requiresUserActionForMediaPlayback = false
        }
        
        // Erstellen und konfigurieren des WebViews
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Deaktiviert das Scrollen innerhalb des Webinhalts
        webView.scrollView.isScrollEnabled = false
        
        // Setzt den Coordinator als Navigation-Delegate
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    // MARK: - updateUIView
    
    /**
     Aktualisiert den Inhalt des `WKWebView`, wenn sich die View ändert
     (oder z. B. die `videoID` aktualisiert wird).
     
     Lädt einen YouTube-Embedded-Link mit `?playsinline=1&fs=0`,
     sodass das Video inline abgespielt wird und
     die Fullscreen-Taste deaktiviert ist.
     
     - Parameter uiView: Der bestehende `WKWebView`.
     - Parameter context: Der SwiftUI-Context für Updates.
     */
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard
            let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&fs=0")
        else { return }
        
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    // MARK: - makeCoordinator
    
    /**
     Erstellt den `Coordinator`, der als `WKNavigationDelegate` fungiert,
     um das WebView-Verhalten (z. B. Navigation) zu überwachen oder zu steuern.
     
     - Returns: Eine Instanz von `Coordinator`.
     */
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Coordinator
    
    /**
     `Coordinator` implementiert das `WKNavigationDelegate`-Protokoll.
     Hier kann auf Navigations- und Ladeereignisse eingegangen werden,
     falls das erforderlich ist (z. B. Fehlerbehandlung, Ladeindikatoren).
     */
    class Coordinator: NSObject, WKNavigationDelegate {
        // Aktuell ohne Implementierung, kann bei Bedarf erweitert werden
    }
}

// MARK: - Preview

/**
 Vorschau für Entwicklungszwecke. Zeigt ein Beispiel-YouTube-Video.
 */
struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView(videoID: "T2QZpy07j4s")
            .frame(height: 200)
    }
}
