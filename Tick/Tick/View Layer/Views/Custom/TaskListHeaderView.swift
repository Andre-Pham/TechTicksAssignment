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
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container.addSubview(self.header)
        
        self.header
            .constrainCenterVertical()
            .constrainLeft(padding: 8)
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
    }
    
    func setContent(header: String) {
        self.self.header.setText(to: header)
    }
    
}
