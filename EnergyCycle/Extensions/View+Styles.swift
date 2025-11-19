//
//  View+Styles.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

extension View {
    // Card style with shadow
    func cardStyle() -> some View {
        self
            .background(Color.color1)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Secondary card style
    func secondaryCardStyle() -> some View {
        self
            .background(Color.mainBack.opacity(0.6))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // Button style with shadow and animation
    func primaryButtonStyle() -> some View {
        self
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.color1, Color.color1.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .shadow(color: Color.color1.opacity(0.4), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
    
    // Small card style
    func smallCardStyle() -> some View {
        self
            .background(Color.colorText.opacity(0.3))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
    }
    
    // Press animation
    func pressAnimation() -> some View {
        self
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: UUID())
    }
}

