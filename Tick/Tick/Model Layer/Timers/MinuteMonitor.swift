//
//  MinuteMonitor.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation

class MinuteMonitor {
    
    private var timer: Timer? = nil
    private var onStartOfMinute: (() -> Void)? = nil
    
    func startMonitoring(callback: @escaping () -> Void) {
        self.onStartOfMinute = callback
        self.scheduleTimerAtStartOfNextMinute()
    }
    
    func endMonitoring() {
        self.timer?.invalidate()
        self.timer = nil
        self.onStartOfMinute = nil
    }
    
    /// Schedule the timer to fire at the start of the next minute
    private func scheduleTimerAtStartOfNextMinute() {
        let currentCalendar = Calendar.current
        let now = Date()
        let nextMinute = currentCalendar.date(byAdding: .minute, value: 1, to: now)!
        let startOfNextMinute = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextMinute)
        let triggerTime = currentCalendar.date(from: startOfNextMinute)!
        let timeInterval = triggerTime.timeIntervalSince(now)
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(self.onMinuteStart), userInfo: nil, repeats: false)
    }
    
    @objc private func onMinuteStart() {
        self.scheduleTimerAtStartOfNextMinute()
        self.onStartOfMinute?()
    }
    
}
