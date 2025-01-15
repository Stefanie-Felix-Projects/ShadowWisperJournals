//
//  YouTubeService.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 14.01.25.
//

import Foundation

class YouTubeService {
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func searchVideos(keyword: String) async throws -> [VideoItem] {
        guard !keyword.isEmpty else { return [] }
        
        let query = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(query)&type=video&maxResults=10&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let searchResponse = try JSONDecoder().decode(YouTubeSearchResult.self, from: data)
        return searchResponse.items
    }
}
