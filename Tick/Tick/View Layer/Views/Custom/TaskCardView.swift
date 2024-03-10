//
//  TaskCard.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskCardView: TickUIView {
    
    private let container = TickContextMenuView()
    private let columnsStack = TickHStack()
    private let contentStack = TickVStack()
    public let title = TickText()
    public let description = TickText()
    public let duration = TickText()
    public let checkBox = CheckBoxView()
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
            .constrainVertical(padding: 14)
            .constrainHorizontal(padding: 16)
            .setSpacing(to: 12)
            .addView(self.contentStack)
            .addView(self.checkBox)
        
        self.contentStack
            .addView(self.title)
            .addView(self.description)
            .addGap(size: 10)
            .addView(self.duration)
        
        self.title
            .setFont(to: TickFont(font: TickFonts.Poppins.SemiBold, size: 18))
            .constrainLeft()
        
        self.description
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 15))
            .setTextColor(to: TickColors.textDark3)
            .constrainLeft()
        
        self.duration
            .setFont(to: TickFont(font: TickFonts.Poppins.Light, size: 14))
            .setTextColor(to: TickColors.textDark3)
            .constrainLeft()
    }
    
    @discardableResult
    func setOnContextMenuActivation(_ callback: (() -> Void)?) -> Self {
        self.container.setOnContextMenuActivation({ interaction, location in
            callback?()
        })
        return self
    }
    
    @discardableResult
    func setOnContextMenuEnd(_ callback: (() -> Void)?) -> Self {
        self.container.setOnContextMenuEnd({ interaction, configuration, animator in
            callback?()
        })
        return self
    }
    
    @discardableResult
    func setContextMenu(to menu: UIMenu?) -> Self {
        self.container.setMenu(to: menu)
        return self
    }
    
    @discardableResult
    func setContent(title: String, description: String, duration: String) -> Self {
        self.title.setText(to: title)
        self.description.setText(to: description)
        self.duration.setText(to: duration)
        return self
    }
    
}
