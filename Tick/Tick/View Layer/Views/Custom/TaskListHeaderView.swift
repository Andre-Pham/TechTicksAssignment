//
//  TaskListHeaderView.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskListHeaderView: TickUIView {
    
    private let container = TickView()
    public let header = TickText()
    public let newTaskButton = TickChipTextButton()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .addSubview(self.header)
            .addSubview(self.newTaskButton)
        
        self.header
            .constrainCenterVertical()
            .constrainLeft(padding: 8)
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
        
        self.newTaskButton
            .constrainCenterVertical()
            .constrainRight(padding: 8)
            .setColor(to: TickColors.primaryComponentFill)
            .setIconColor(to: TickColors.textPrimaryComponent)
            .setIcon(to: "note.text.badge.plus")
            .setLabel(to: Strings("button.new").local)
    }
    
    func setContent(header: String) {
        self.self.header.setText(to: header)
    }
    
}
