//
//  EnergyPoint.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

struct EnergyPoint: Codable, Identifiable {
    let id: UUID
    let time: Date
    var physicalEnergy: Double // 0.0 - 1.0
    var mentalEnergy: Double // 0.0 - 1.0
    var userReported: Bool // true если введено пользователем
    
    init(id: UUID = UUID(), time: Date, physicalEnergy: Double, mentalEnergy: Double, userReported: Bool = false) {
        self.id = id
        self.time = time
        self.physicalEnergy = max(0.0, min(1.0, physicalEnergy))
        self.mentalEnergy = max(0.0, min(1.0, mentalEnergy))
        self.userReported = userReported
    }
    
    var averageEnergy: Double {
        return (physicalEnergy + mentalEnergy) / 2.0
    }
}

