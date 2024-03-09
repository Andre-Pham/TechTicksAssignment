//
//  TaskListHeaderView.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskListHeaderView<T>: TickUIView {
    
    private static var HORIZONTAL_PADDING: Double { 8.0 }
    
    private let container = TickView()
    private let stack = TickVStack()
    private let headerRow = TickHStack()
    public let header = TickText()
    public let newTaskButton = TickChipTextButton()
    public let filterControls = HorizontalChipButtonsView<T>()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .addSubview(self.stack)
        
        self.stack
            .constrainHorizontal()
            .addGap(size: 12)
            .addView(self.headerRow)
            .addGap(size: 12)
            .addView(self.filterControls)
        
        self.headerRow
            .constrainHorizontal()
            .addGap(size: Self.HORIZONTAL_PADDING)
            .addView(self.header)
            .addSpacer()
            .addView(self.newTaskButton)
            .addGap(size: Self.HORIZONTAL_PADDING)
        
        self.filterControls
            .constrainHorizontal(padding: Self.HORIZONTAL_PADDING)
        
        self.header
            .constrainCenterVertical()
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
        
        self.newTaskButton
            .constrainCenterVertical()
            .setColor(to: TickColors.primaryComponentFill)
            .setIconColor(to: TickColors.textPrimaryComponent)
            .setIcon(to: "note.text.badge.plus")
            .setLabel(to: Strings("button.new").local)
    }
    
    @discardableResult
    func setContent(header: String) -> Self {
        self.self.header.setText(to: header)
        return self
    }
    
}
