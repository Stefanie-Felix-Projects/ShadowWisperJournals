//
//  LocationSection.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 21.01.25.
//

import SwiftUI

struct LocationSection: View {
    @Binding var localLocationString: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Standort / Karte")
                .font(.custom("SmoochSans-Bold", size: 22))
                .foregroundColor(AppColors.signalColor4)
            
            TextField("Standort-Adresse", text: $localLocationString)
                .font(.system(size: 18))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
            
            GoogleMapView(locationString: localLocationString)
                .frame(height: 200)
                .cornerRadius(12)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}
