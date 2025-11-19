//
//  EnergyCycleStorage.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

class EnergyCycleStorage {
    static let shared = EnergyCycleStorage()
    
    private let userDefaults = UserDefaults.standard
    private let energyCyclesKey = "energyCycles"
    
    private init() {}
    
    // Сохранить цикл энергии
    func save(_ energyCycle: EnergyCycle) {
        var cycles = loadAll()
        
        // Удалить старый цикл для этой даты, если есть
        let calendar = Calendar.current
        cycles.removeAll { cycle in
            calendar.isDate(cycle.date, inSameDayAs: energyCycle.date)
        }
        
        cycles.append(energyCycle)
        
        if let encoded = try? JSONEncoder().encode(cycles) {
            userDefaults.set(encoded, forKey: energyCyclesKey)
        }
    }
    
    // Загрузить цикл для конкретной даты
    func load(for date: Date) -> EnergyCycle? {
        let cycles = loadAll()
        let calendar = Calendar.current
        
        return cycles.first { cycle in
            calendar.isDate(cycle.date, inSameDayAs: date)
        }
    }
    
    // Загрузить все циклы
    func loadAll() -> [EnergyCycle] {
        guard let data = userDefaults.data(forKey: energyCyclesKey),
              let cycles = try? JSONDecoder().decode([EnergyCycle].self, from: data) else {
            return []
        }
        return cycles
    }
    
    // Получить или создать цикл для сегодня
    func getOrCreateToday() -> EnergyCycle {
        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        
        if let existing = load(for: startOfDay) {
            return existing
        }
        
        let defaultLevels = EnergyCycle.createDefaultEnergyPattern(for: startOfDay)
        let newCycle = EnergyCycle(date: startOfDay, energyLevels: defaultLevels)
        save(newCycle)
        return newCycle
    }
}

