//
//  TaskCard.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskCardView: TickUIView {
    
    private let container = TickView()
    private let columnsStack = TickHStack()
    private let contentStack = TickVStack()
    public let title = TickText()
    public let description = TickText()
    public let duration = TickText()
    public let status = TickText()
    public let completedToggle = TickChipToggle()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setBackgroundColor(to: TickColors.foregroundFill)
            .setCornerRadius(to: TickDimensions.foregroundCornerRadius)
            .addSubview(self.columnsStack)
        
        self.columnsStack
            .constrainVertical(padding: 16)
            .constrainHorizontal(padding: 18)
            .setSpacing(to: 12)
            .addView(self.contentStack)
            .addView(self.completedToggle)
        
        self.contentStack
            .setSpacing(to: 2)
            .addView(self.status)
            .addView(self.title)
            .addView(self.description)
            .addView(self.duration)
        
        self.status
            .setFont(to: TickFont(font: TickFonts.Poppins.Light, size: 12))
            .setTextColor(to: TickColors.textDark3)
            .constrainHorizontal()
        
        self.title
            .setFont(to: TickFont(font: TickFonts.Poppins.SemiBold, size: 18))
            .constrainHorizontal()
        
        self.description
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark3)
            .constrainHorizontal()
        
        self.duration
            .setFont(to: TickFont(font: TickFonts.Poppins.Light, size: 12))
            .setTextColor(to: TickColors.textDark3)
            .constrainHorizontal()
    }
    
    func setContent(title: String, description: String, duration: String, status: String) {
        self.title.setText(to: title)
        self.description.setText(to: description)
        self.duration.setText(to: duration)
        self.status.setText(to: status)
    }
    
}
