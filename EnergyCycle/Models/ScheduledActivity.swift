//
//  ScheduledActivity.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

struct ScheduledActivity: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: ActivityType
    var scheduledTime: Date
    var duration: TimeInterval
    var priority: Priority
    
    init(id: UUID = UUID(), title: String, type: ActivityType, scheduledTime: Date, duration: TimeInterval, priority: Priority) {
        self.id = id
        self.title = title
        self.type = type
        self.scheduledTime = scheduledTime
        self.duration = duration
        self.priority = priority
    }
    
    var endTime: Date {
        return scheduledTime.addingTimeInterval(duration)
    }
}

