//
//  ActivityType.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation
import SwiftUI

enum ActivityType: String, CaseIterable, Codable {
    case deepWork = "Deep Work"
    case creativeWork = "Creative Work"
    case meetings = "Meetings"
    case learning = "Learning"
    case physicalHigh = "High Activity"
    case physicalMedium = "Medium Activity"
    case physicalLow = "Low Activity"
    case recovery = "Recovery"
    
    var icon: String {
        switch self {
        case .deepWork: return "brain.head.profile"
        case .creativeWork: return "paintbrush.fill"
        case .meetings: return "person.2.fill"
        case .learning: return "book.fill"
        case .physicalHigh: return "flame.fill"
        case .physicalMedium: return "figure.walk"
        case .physicalLow: return "figure.mind.and.body"
        case .recovery: return "bed.double.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .deepWork: return .blue
        case .creativeWork: return .purple
        case .meetings: return .orange
        case .learning: return .green
        case .physicalHigh: return .red
        case .physicalMedium: return .orange
        case .physicalLow: return .yellow
        case .recovery: return .indigo
        }
    }
}

