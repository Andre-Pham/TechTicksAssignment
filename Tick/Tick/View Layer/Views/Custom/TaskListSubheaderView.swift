//
//  TaskListSubheader.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskListSubheaderView: TickUIView {
    
    private let container = TickView()
    public let subheader = TickText()
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container.addSubview(self.subheader)
        
        self.subheader
            .constrainCenterVertical()
            .constrainLeft(padding: 24)
            .setFont(to: TickFont(font: TickFonts.Quicksand.Bold, size: 24))
    }
    
    func setContent(subheader: String) {
        self.self.subheader.setText(to: subheader)
    }
    
}

