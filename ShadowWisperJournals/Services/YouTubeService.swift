//
//  YouTubeService.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import Foundation

/// Die `YouTubeService`-Klasse bietet Funktionen zur Kommunikation mit der YouTube Data API,
/// um Videos basierend auf Suchbegriffen zu suchen.
class YouTubeService {
    /// Der API-Schlüssel für die Authentifizierung bei der YouTube Data API.
    private let apiKey: String
    
    /// Initialisiert den `YouTubeService` mit einem API-Schlüssel.
    /// - Parameter apiKey: Der API-Schlüssel für die YouTube Data API.
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Führt eine asynchrone Suche nach Videos durch, die dem angegebenen Schlüsselwort entsprechen.
    /// - Parameter keyword: Der Suchbegriff, nach dem Videos gesucht werden sollen.
    /// - Returns: Eine Liste von `VideoItem`-Objekten, die die Suchergebnisse repräsentieren.
    /// - Throws: Fehler, wenn die URL ungültig ist, die Netzwerkverbindung fehlschlägt
    ///   oder die API einen unerwarteten Statuscode zurückgibt.
    func searchVideos(keyword: String) async throws -> [VideoItem] {
        // Gibt eine leere Liste zurück, wenn der Suchbegriff leer ist.
        guard !keyword.isEmpty else { return [] }
        
        // Kodiert den Suchbegriff für die Verwendung in einer URL.
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Baut die URL für die YouTube Data API-Suche.
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=video&maxResults=10&key=\(apiKey)"
        
        // Überprüft, ob die URL gültig ist, und wirft einen Fehler, wenn nicht.
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        // Führt die Netzwerkanfrage aus und empfängt die Antwort.
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Überprüft den HTTP-Statuscode und wirft einen Fehler bei ungültigen Codes.
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        // Dekodiert die JSON-Antwort in ein `YouTubeSearchResult`-Objekt.
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResult.self, from: data)
        
        // Gibt die Liste der Videos zurück, die in der Antwort enthalten sind.
        return searchResponse.items
    }
}
