//
//  YouTubePlayerView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
// Test

import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        } else {
            configuration.requiresUserActionForMediaPlayback = false
        }
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard
            let url = URL(
                string: "https://www.youtube.com/embed/\(videoID)?playsinline=1&fs=0"
            )
        else { return }

        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        // Hier kannst du weitere Navigation Delegate Methoden implementieren, falls nötig
    }
}

struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView(videoID: "T2QZpy07j4s")
    }
}
