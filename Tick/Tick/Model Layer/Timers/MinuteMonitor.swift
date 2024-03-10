//
//  MinuteMonitor.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation

/// Monitors minutes - triggers a callback at the start of every new minute.
class MinuteMonitor {
    
    /// The timer to track the passage of time
    private var timer: Timer? = nil
    /// The stored callback to trigger at every minute
    private var onStartOfMinute: (() -> Void)? = nil
    
    /// Start receiving callbacks at the start of every minute
    /// - Parameters:
    ///   - callback: The callback to trigger at the start of every minute
    func startMonitoring(callback: @escaping () -> Void) {
        self.onStartOfMinute = callback
        self.scheduleTimerAtStartOfNextMinute()
    }
    
    /// Stop receiving callbacks and end the timer (stop monitoring time)
    func endMonitoring() {
        self.timer?.invalidate()
        self.timer = nil
        self.onStartOfMinute = nil
    }
    
    /// Schedules the timer to fire at the start of the next minute
    private func scheduleTimerAtStartOfNextMinute() {
        let currentCalendar = Calendar.current
        let now = Date()
        let nextMinute = currentCalendar.date(byAdding: .minute, value: 1, to: now)!
        let startOfNextMinute = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextMinute)
        let triggerTime = currentCalendar.date(from: startOfNextMinute)!
        let timeInterval = triggerTime.timeIntervalSince(now)
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.onMinuteStart), userInfo: nil, repeats: false)
    }
    
    /// The target function that triggers at the beginning of a minute
    @objc private func onMinuteStart() {
        // Schedule a new timer for the start of the NEXT minute
        self.scheduleTimerAtStartOfNextMinute()
        // Trigger the callback
        self.onStartOfMinute?()
    }
    
}
