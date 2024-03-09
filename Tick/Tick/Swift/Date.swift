//
//  Date.swift
//  Tick
//
//  Created by Andre Pham on 9/3/2024.
//

import Foundation

import Foundation

extension Date {
    
    /// Rounds the date to the nearest specified date component value.
    /// - Parameters:
    ///   - component: The component to round to (e.g., .minute, .hour).
    ///   - nearest: The interval value to round to (e.g., 30 for minutes).
    func rounded(to component: Calendar.Component, nearest: Int) -> Date? {
        let calendar = Calendar.current
        let currentValue = calendar.component(component, from: self)
        let roundingValue = nearest
        let remainder = currentValue % roundingValue
        let roundDownAmount = -remainder
        let roundUpAmount = roundingValue - remainder
        let nearest = abs(roundDownAmount) < abs(roundUpAmount) ? roundDownAmount : roundUpAmount
        return calendar.date(byAdding: component, value: nearest, to: self)
    }

    /// Rounds the date to the nearest future specified date component value.
    /// - Parameters:
    ///   - component: The component to round to (e.g., .minute, .hour).
    ///   - nearest: The interval value to round to (e.g., 30 for minutes).
    func roundedToFuture(to component: Calendar.Component, nearest: Int) -> Date? {
        let calendar = Calendar.current
        let currentValue = calendar.component(component, from: self)
        let roundingValue = nearest
        let remainder = currentValue % roundingValue
        let roundUpAmount = roundingValue - remainder
        return calendar.date(byAdding: component, value: roundUpAmount, to: self)
    }

    /// Rounds the date to the nearest past specified date component value.
    /// - Parameters:
    ///   - component: The component to round to (e.g., .minute, .hour).
    ///   - nearest: The interval value to round to (e.g., 30 for minutes).
    func roundedToPast(to component: Calendar.Component, nearest: Int) -> Date? {
        let calendar = Calendar.current
        let currentValue = calendar.component(component, from: self)
        let roundingValue = nearest
        let remainder = currentValue % roundingValue
        let roundDownAmount = -remainder
        return calendar.date(byAdding: component, value: roundDownAmount, to: self)
    }
    
}
