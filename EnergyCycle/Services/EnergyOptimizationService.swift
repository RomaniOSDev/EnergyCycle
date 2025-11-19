//
//  EnergyOptimizationService.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

class EnergyOptimizationService {
    
    // Определение оптимального времени для активности
    static func optimalTime(for activity: ActivityType, energyCycle: EnergyCycle) -> Date? {
        switch activity {
        case .deepWork:
            return findPeakTime(for: \.mentalEnergy, in: energyCycle)
        case .physicalHigh:
            return findPeakTime(for: \.physicalEnergy, in: energyCycle)
        case .creativeWork:
            return findModerateTime(for: \.mentalEnergy, in: energyCycle)
        case .meetings:
            return findStableTime(for: \.mentalEnergy, in: energyCycle)
        case .learning:
            return findModerateTime(for: \.mentalEnergy, in: energyCycle)
        case .physicalMedium:
            return findModerateTime(for: \.physicalEnergy, in: energyCycle)
        case .physicalLow:
            return findLowTime(for: \.physicalEnergy, in: energyCycle)
        case .recovery:
            return findLowAverageTime(in: energyCycle)
        }
    }
    
    // Найти пиковое время для определенного типа энергии
    private static func findPeakTime(for keyPath: KeyPath<EnergyPoint, Double>, in energyCycle: EnergyCycle) -> Date? {
        let sortedLevels = energyCycle.energyLevels.sorted { $0.time < $1.time }
        guard let peak = sortedLevels.max(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] }) else {
            return nil
        }
        return peak.time
    }
    
    // Найти умеренное время (не слишком высокое, не слишком низкое)
    private static func findModerateTime(for keyPath: KeyPath<EnergyPoint, Double>, in energyCycle: EnergyCycle) -> Date? {
        let sortedLevels = energyCycle.energyLevels.sorted { $0.time < $1.time }
        guard !sortedLevels.isEmpty else { return nil }
        
        let values = sortedLevels.map { $0[keyPath: keyPath] }
        let average = values.reduce(0, +) / Double(values.count)
        
        // Найти время ближайшее к среднему значению
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Предпочитаем время в будущем
        let futureLevels = sortedLevels.filter { calendar.component(.hour, from: $0.time) >= currentHour }
        
        if let best = futureLevels.min(by: { abs($0[keyPath: keyPath] - average) < abs($1[keyPath: keyPath] - average) }) {
            return best.time
        }
        
        return sortedLevels.first?.time
    }
    
    // Найти время с низкой энергией
    private static func findLowTime(for keyPath: KeyPath<EnergyPoint, Double>, in energyCycle: EnergyCycle) -> Date? {
        let sortedLevels = energyCycle.energyLevels.sorted { $0.time < $1.time }
        guard let low = sortedLevels.min(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] }) else {
            return nil
        }
        return low.time
    }
    
    // Найти стабильное время (минимальная вариативность)
    private static func findStableTime(for keyPath: KeyPath<EnergyPoint, Double>, in energyCycle: EnergyCycle) -> Date? {
        let sortedLevels = energyCycle.energyLevels.sorted { $0.time < $1.time }
        guard sortedLevels.count >= 2 else {
            return sortedLevels.first?.time
        }
        
        // Найти период с наименьшей вариативностью
        var bestTime: Date?
        var minVariance = Double.infinity
        
        for i in 0..<sortedLevels.count - 1 {
            let current = sortedLevels[i]
            let next = sortedLevels[i + 1]
            let variance = abs(current[keyPath: keyPath] - next[keyPath: keyPath])
            
            if variance < minVariance {
                minVariance = variance
                bestTime = current.time
            }
        }
        
        return bestTime ?? sortedLevels.first?.time
    }
    
    // Найти время с низкой средней энергией
    private static func findLowAverageTime(in energyCycle: EnergyCycle) -> Date? {
        let sortedLevels = energyCycle.energyLevels.sorted { $0.time < $1.time }
        guard let low = sortedLevels.min(by: { $0.averageEnergy < $1.averageEnergy }) else {
            return nil
        }
        return low.time
    }
    
    // Рекомендация времени для задачи
    static func recommendTime(for activity: ScheduledActivity, in energyCycle: EnergyCycle) -> Date? {
        return optimalTime(for: activity.type, energyCycle: energyCycle)
    }
}

