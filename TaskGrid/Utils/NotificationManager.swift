//
//  NotificationManager.swift
//  TaskGrid
//
//  Created by Nishil Soni on 09/11/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error:", error)
            } else {
                print("Notifications permission:", granted)
            }
        }
    }

    func scheduleNotification(for task: Task, minutesBefore: Int) {
        guard let dueDate = task.dueDate else { return }

        let triggerTime = dueDate.addingTimeInterval(TimeInterval(-minutesBefore * 60))
        if triggerTime < Date() { return } // don’t schedule past reminders

        let content = UNMutableNotificationContent()
        content.title = "\(task.emoji) \(task.title)"
        content.body = "Due soon (\(minutesBefore) min left)!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerTime),
            repeats: false
        )

        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err { print("Failed to schedule:", err.localizedDescription) }
        }
        print("⏰ Scheduled for:", triggerTime)
    }

    func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
}
