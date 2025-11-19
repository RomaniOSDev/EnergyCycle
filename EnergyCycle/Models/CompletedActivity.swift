//
//  CompletedActivity.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation

struct CompletedActivity: Identifiable, Codable {
    let id: UUID
    var activityId: UUID?
    var title: String
    var type: ActivityType
    var startTime: Date
    var endTime: Date
    var effectiveness: Double? // оценка эффективности 0-1
    
    init(id: UUID = UUID(), activityId: UUID? = nil, title: String, type: ActivityType, startTime: Date, endTime: Date, effectiveness: Double? = nil) {
        self.id = id
        self.activityId = activityId
        self.title = title
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.effectiveness = effectiveness.map { max(0.0, min(1.0, $0)) }
    }
    
    var duration: TimeInterval {
        return endTime.timeIntervalSince(startTime)
    }
}

