//
//  EnergyCycle.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

struct EnergyCycle: Identifiable, Codable {
    let id: UUID
    let date: Date
    var energyLevels: [EnergyPoint] // точки энергии в течение дня
    var plannedActivities: [ScheduledActivity]
    var actualActivities: [CompletedActivity]
    
    init(id: UUID = UUID(), date: Date, energyLevels: [EnergyPoint] = [], plannedActivities: [ScheduledActivity] = [], actualActivities: [CompletedActivity] = []) {
        self.id = id
        self.date = date
        self.energyLevels = energyLevels
        self.plannedActivities = plannedActivities
        self.actualActivities = actualActivities
    }
    
    // Получить уровень энергии в определенное время (интерполяция)
    func energyLevel(at time: Date) -> (physical: Double, mental: Double) {
        let calendar = Calendar.current
        let timeOfDay = calendar.dateComponents([.hour, .minute], from: time)
        
        guard let timeHour = timeOfDay.hour else {
            return (0.5, 0.5)
        }
        
        // Найти ближайшие точки энергии
        let sortedLevels = energyLevels.sorted { $0.time < $1.time }
        
        if sortedLevels.isEmpty {
            return (0.5, 0.5)
        }
        
        // Если есть только одна точка или время до первой точки
        if sortedLevels.count == 1 || time < sortedLevels.first!.time {
            let first = sortedLevels.first!
            return (first.physicalEnergy, first.mentalEnergy)
        }
        
        // Если время после последней точки
        if time > sortedLevels.last!.time {
            let last = sortedLevels.last!
            return (last.physicalEnergy, last.mentalEnergy)
        }
        
        // Найти две ближайшие точки для интерполяции
        for i in 0..<sortedLevels.count - 1 {
            let current = sortedLevels[i]
            let next = sortedLevels[i + 1]
            
            if time >= current.time && time <= next.time {
                let totalInterval = next.time.timeIntervalSince(current.time)
                let currentInterval = time.timeIntervalSince(current.time)
                let ratio = totalInterval > 0 ? currentInterval / totalInterval : 0
                
                let physical = current.physicalEnergy + (next.physicalEnergy - current.physicalEnergy) * ratio
                let mental = current.mentalEnergy + (next.mentalEnergy - current.mentalEnergy) * ratio
                
                return (physical, mental)
            }
        }
        
        return (0.5, 0.5)
    }
}

// MARK: - Default Energy Pattern
extension EnergyCycle {
    static func createDefaultEnergyPattern(for date: Date) -> [EnergyPoint] {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        func createTime(hour: Int) -> Date {
            components.hour = hour
            components.minute = 0
            return calendar.date(from: components) ?? date
        }
        
        return [
            EnergyPoint(time: createTime(hour: 7), physicalEnergy: 0.7, mentalEnergy: 0.6, userReported: false),
            EnergyPoint(time: createTime(hour: 10), physicalEnergy: 0.9, mentalEnergy: 0.8, userReported: false),
            EnergyPoint(time: createTime(hour: 14), physicalEnergy: 0.6, mentalEnergy: 0.5, userReported: false),
            EnergyPoint(time: createTime(hour: 17), physicalEnergy: 0.8, mentalEnergy: 0.7, userReported: false),
            EnergyPoint(time: createTime(hour: 21), physicalEnergy: 0.4, mentalEnergy: 0.3, userReported: false)
        ]
    }
}

