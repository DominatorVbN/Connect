//
//  Globals.swift
//  Connect
//
//  Created by Amit Samant on 06/12/24.
//

import SwiftUI

extension Color {
    static func pastelColor(for uuid: UUID, in colorScheme: ColorScheme) -> Color {
         let hashValue = uuid.uuidString.hash
         
         // Normalize the hash to a value between 0 and 1 for hue
         let normalizedHash = Double(abs(hashValue % 1000)) / 1000.0
         
         // Define pastel HSB values
         let hue = normalizedHash
         let saturation: Double = 0.4 // Lower saturation for pastel colors
         let brightness: Double = colorScheme == .dark ? 0.8 : 0.9 // High brightness
         
         return Color(hue: hue, saturation: saturation, brightness: brightness)
     }
}
