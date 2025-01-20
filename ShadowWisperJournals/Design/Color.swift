//
//  Color.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 20.01.25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                            .uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        var rgb: UInt64 = 0x999999

        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8)  / 255.0
        let b = Double(rgb & 0x0000FF)        / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

struct AppColors {
    // Standard Farben
    static let color1 = Color(hex: "#1c293b")
    static let color2 = Color(hex: "#02050f")
    static let color3 = Color(hex: "#01060f")
    static let color4 = Color(hex: "#01040e")
    static let color5 = Color(hex: "#01030e")
    static let color6 = Color(hex: "#020510")
    static let color7 = Color(hex: "#162233")
    static let color8 = Color(hex: "#050713")
    static let color9 = Color(hex: "#1d2a3d")
    static let color10 = Color(hex: "#162030")

    // Signalfarben
    static let signalColor1 = Color(hex: "#e49399")
    static let signalColor2 = Color(hex: "#fce3be")
    static let signalColor3 = Color(hex: "#fbd0b6")
    static let signalColor4 = Color(hex: "#ce87ad")
    static let signalColor5 = Color(hex: "#f9be8d")

    // Gradient-Farben
    static let gradientColors: [Color] = [
        color1, color2, color3, color4, color5,
        color6, color7, color8, color9, color10,
    ]
}
