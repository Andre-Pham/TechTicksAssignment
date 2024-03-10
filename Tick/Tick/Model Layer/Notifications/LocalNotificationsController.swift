//
//  NotificationController.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UserNotifications
import UIKit

/// A controller for managing the application's local notifications.
class LocalNotificationsController: NSObject, UNUserNotificationCenterDelegate {
    
    /// Singleton instance
    public static let inst = LocalNotificationsController()
    
    /// True if authorization has been granted to trigger notifications (alert, sound, badge)
    private(set) var authorizationGranted = false
    
    private override init() { }
    
    /// Requests for the app to have permission to trigger notifications
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.authorizationGranted = granted
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
    
    /// Reset the app's notification badge to nothing
    func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    /// Schedule a new notification
    /// - Parameters:
    ///   - id: The id of the notification (may be referenced when deleting notifications)
    ///   - title: The notification banner title
    ///   - body: The notification banner's body text
    ///   - trigger: The exact date/time to trigger at (to the minute)
    func scheduleNotification(id: String, title: String, body: String, trigger: Date) {
        guard self.authorizationGranted else {
            return
        }
        // Configure the notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        // Badges are always 1 or none
        // Badge count has to be determined at the time the notification is scheduled
        // You can't increment it because you won't know the badge count at the time the notification triggers
        // (E.g. if you schedule a badge of 2 and the user opens the app just before it triggers, hence resetting the badge count, the scheduled badge of 2 is incorrect)
        // For dynamic badge counts a server is needed
        content.badge = 1
        // Configure and add the request
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: trigger)
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        UNUserNotificationCenter.current().add(request) { error in
            // Note: if error is nil, the notification was successfully scheduled
            if let error = error {
                assertionFailure("Failed to schedule notification: \(error)")
            }
        }
    }
    
    /// De-schedules a notification based on its id
    /// - Parameters:
    ///   - id: The id of the notification to be removed
    func removeNotification(id: String) {
        self.removeNotifications(ids: [id])
    }
    
    /// De-schedules notifications based on their id
    /// - Parameters:
    ///   - ids: The ids of the notifications to be removed
    func removeNotifications(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    /// De-schedules all scheduled notifications
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Callback conforming to UNUserNotificationCenterDelegate on how to handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handles notification delivery while the app is in the foreground
        // We want notifications to still trigger
        completionHandler([.banner, .sound])
    }
    
    /// Callback conforming to UNUserNotificationCenterDelegate for after a notification has been received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
