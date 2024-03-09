//
//  TaskListSubheader.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskListSectionHeaderView: TickUIView {
    
    private let container = TickView()
    public let sectionHeader = TickText()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(self.sectionHeader)
        
        self.sectionHeader
            .constrainCenterVertical()
            .constrainLeft(padding: 18)
            .setFont(to: TickFont(font: TickFonts.Poppins.SemiBold, size: 14))
    }
    
    @discardableResult
    func setContent(subheader: String) -> Self {
        self.self.sectionHeader.setText(to: subheader)
        return self
    }
    
}
