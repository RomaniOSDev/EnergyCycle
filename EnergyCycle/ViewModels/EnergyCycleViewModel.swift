//
//  EnergyCycleViewModel.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation
import Combine

class EnergyCycleViewModel: ObservableObject {
    @Published var energyCycle: EnergyCycle
    @Published var selectedTime: Date = Date()
    @Published var showingAddActivity = false
    @Published var showingEnergyInput = false
    
    private let storage = EnergyCycleStorage.shared
    private let optimizationService = EnergyOptimizationService.self
    
    init() {
        self.energyCycle = storage.getOrCreateToday()
    }
    
    // Обновить уровень энергии в определенное время
    func updateEnergyLevel(at time: Date, physical: Double, mental: Double) {
        let calendar = Calendar.current
        let timeOfDay = calendar.dateComponents([.hour, .minute], from: time)
        
        // Найти существующую точку или создать новую
        if let index = energyCycle.energyLevels.firstIndex(where: { point in
            let pointComponents = calendar.dateComponents([.hour, .minute], from: point.time)
            return pointComponents.hour == timeOfDay.hour && pointComponents.minute == timeOfDay.minute
        }) {
            energyCycle.energyLevels[index].physicalEnergy = physical
            energyCycle.energyLevels[index].mentalEnergy = mental
            energyCycle.energyLevels[index].userReported = true
        } else {
            let newPoint = EnergyPoint(
                time: time,
                physicalEnergy: physical,
                mentalEnergy: mental,
                userReported: true
            )
            energyCycle.energyLevels.append(newPoint)
            energyCycle.energyLevels.sort { $0.time < $1.time }
        }
        
        save()
    }
    
    // Добавить запланированную активность
    func addActivity(_ activity: ScheduledActivity) {
        energyCycle.plannedActivities.append(activity)
        energyCycle.plannedActivities.sort { $0.scheduledTime < $1.scheduledTime }
        save()
    }
    
    // Удалить запланированную активность
    func removeActivity(_ activity: ScheduledActivity) {
        energyCycle.plannedActivities.removeAll { $0.id == activity.id }
        save()
    }
    
    // Отметить активность как выполненную
    func completeActivity(_ activity: ScheduledActivity) {
        let completed = CompletedActivity(
            activityId: activity.id,
            title: activity.title,
            type: activity.type,
            startTime: activity.scheduledTime,
            endTime: activity.scheduledTime.addingTimeInterval(activity.duration)
        )
        energyCycle.actualActivities.append(completed)
        energyCycle.plannedActivities.removeAll { $0.id == activity.id }
        save()
    }
    
    // Обновить активность
    func updateActivity(_ updatedActivity: ScheduledActivity) {
        if let index = energyCycle.plannedActivities.firstIndex(where: { $0.id == updatedActivity.id }) {
            energyCycle.plannedActivities[index] = updatedActivity
            energyCycle.plannedActivities.sort { $0.scheduledTime < $1.scheduledTime }
            save()
        }
    }
    
    // Получить рекомендацию времени для активности
    func recommendTime(for activityType: ActivityType) -> Date? {
        return optimizationService.optimalTime(for: activityType, energyCycle: energyCycle)
    }
    
    // Получить уровень энергии в определенное время
    func getEnergyLevel(at time: Date) -> (physical: Double, mental: Double) {
        return energyCycle.energyLevel(at: time)
    }
    
    // Сохранить изменения
    private func save() {
        storage.save(energyCycle)
    }
    
    // Получить текущий уровень энергии
    var currentEnergyLevel: (physical: Double, mental: Double) {
        return energyCycle.energyLevel(at: Date())
    }
    
    // Получить запланированные активности на сегодня
    var todayActivities: [ScheduledActivity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return energyCycle.plannedActivities.filter { activity in
            activity.scheduledTime >= today && activity.scheduledTime < tomorrow
        }
    }
    
    // Загрузить цикл для конкретной даты
    func loadCycle(for date: Date) {
        if let cycle = storage.load(for: date) {
            self.energyCycle = cycle
        } else {
            let defaultLevels = EnergyCycle.createDefaultEnergyPattern(for: date)
            self.energyCycle = EnergyCycle(date: calendar.startOfDay(for: date), energyLevels: defaultLevels)
        }
    }
    
    // Получить все доступные даты с данными
    var availableDates: [Date] {
        let allCycles = storage.loadAll()
        return allCycles.map { $0.date }.sorted(by: >)
    }
    
    // Получить статистику за период
    func getStatistics(for days: Int) -> EnergyStatistics {
        let allCycles = storage.loadAll()
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) else {
            return EnergyStatistics()
        }
        
        let filteredCycles = allCycles.filter { cycle in
            cycle.date >= startDate && cycle.date <= endDate
        }
        
        return EnergyStatistics(from: filteredCycles)
    }
    
    // Экспорт данных в JSON
    func exportToJSON() -> String? {
        let allCycles = storage.loadAll()
        guard let jsonData = try? JSONEncoder().encode(allCycles),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    // Экспорт данных в CSV
    func exportToCSV() -> String {
        let allCycles = storage.loadAll()
        var csv = "Date,Time,Physical Energy,Mental Energy,User Reported,Activity Title,Activity Type,Activity Start,Activity End,Activity Priority\n"
        
        for cycle in allCycles {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: cycle.date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
            // Экспорт точек энергии
            for point in cycle.energyLevels {
                let timeString = timeFormatter.string(from: point.time)
                csv += "\(dateString),\(timeString),\(point.physicalEnergy),\(point.mentalEnergy),\(point.userReported ? "Yes" : "No"),,,,,\n"
            }
            
            // Экспорт активностей
            for activity in cycle.plannedActivities {
                let startString = timeFormatter.string(from: activity.scheduledTime)
                let endString = timeFormatter.string(from: activity.endTime)
                csv += "\(dateString),\(startString),,,,\(activity.title),\(activity.type.rawValue),\(startString),\(endString),\(activity.priority.rawValue)\n"
            }
            
            // Экспорт выполненных активностей
            for activity in cycle.actualActivities {
                let startString = timeFormatter.string(from: activity.startTime)
                let endString = timeFormatter.string(from: activity.endTime)
                csv += "\(dateString),\(startString),,,,\(activity.title),\(activity.type.rawValue),\(startString),\(endString),Completed\n"
            }
        }
        
        return csv
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
}

// MARK: - Statistics Model
struct EnergyStatistics {
    var totalDays: Int = 0
    var averagePhysicalEnergy: Double = 0
    var averageMentalEnergy: Double = 0
    var totalActivities: Int = 0
    var completedActivities: Int = 0
    var completionRate: Double = 0
    
    init() {}
    
    init(from cycles: [EnergyCycle]) {
        self.totalDays = cycles.count
        
        var totalPhysical: Double = 0
        var totalMental: Double = 0
        var totalPoints: Int = 0
        
        for cycle in cycles {
            for point in cycle.energyLevels {
                totalPhysical += point.physicalEnergy
                totalMental += point.mentalEnergy
                totalPoints += 1
            }
            
            self.totalActivities += cycle.plannedActivities.count
            self.completedActivities += cycle.actualActivities.count
        }
        
        if totalPoints > 0 {
            self.averagePhysicalEnergy = totalPhysical / Double(totalPoints)
            self.averageMentalEnergy = totalMental / Double(totalPoints)
        }
        
        if totalActivities > 0 {
            self.completionRate = Double(completedActivities) / Double(totalActivities)
        }
    }
}

