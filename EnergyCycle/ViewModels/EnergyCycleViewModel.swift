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
}

