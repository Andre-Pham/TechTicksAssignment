//
//  NotificationController.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UserNotifications
import UIKit

class LocalNotificationsController: NSObject, UNUserNotificationCenterDelegate {
    
    /// Singleton instance
    public static let inst = LocalNotificationsController()
    
    private(set) var authorizationGranted = false
    
    private override init() { }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.authorizationGranted = granted
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
    }
    
    func resetBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func scheduleNotification(id: String, title: String, body: String, trigger: Date) {
        guard self.authorizationGranted else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        
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
    
    func removeNotification(id: String) {
        self.removeNotifications(ids: [id])
    }
    
    func removeNotifications(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handles notification delivery while the app is in the foreground
        // We want notifications to still trigger
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
