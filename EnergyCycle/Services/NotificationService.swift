//
//  NotificationService.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                self.scheduleEnergyReminders()
            }
        }
    }
    
    func scheduleEnergyReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // Напоминания в 9:00, 13:00, 17:00, 21:00
        let times = [9, 13, 17, 21]
        
        for hour in times {
            let content = UNMutableNotificationContent()
            content.title = "Energy Assessment"
            content.body = "Time to assess your energy levels for optimal planning!"
            content.sound = .default
            content.badge = 1
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "energyReminder_\(hour)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

