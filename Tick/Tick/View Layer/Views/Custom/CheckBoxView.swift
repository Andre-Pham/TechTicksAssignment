//
//  CheckBoxView.swift
//  Tick
//
//  Created by Andre Pham on 9/3/2024.
//

import Foundation
import UIKit

class CheckBoxView: TickUIView {
    
    private static let BORDER_WIDTH = 2.0
    
    private let container = TickView()
    private let icon = TickImage()
    private let control = TickControl()
    private var onRelease: ((_ checked: Bool) -> Void)? = nil
    private var uncheckedColor = TickColors.textDark2
    private var checkedColor = TickColors.accent
    private var iconColor = TickColors.whitePermanent
    private(set) var isChecked = false
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setWidthConstraint(to: 32)
            .setHeightConstraint(to: 32)
            .setCornerRadius(to: 16)
            .addSubview(self.icon)
            .addSubview(self.control)
        
        self.icon
            .constrainAllSides(padding: 6)
        
        self.control
            .constrainAllSides()
            .setOnRelease({
                self.isChecked.toggle()
                self.refresh()
                self.onRelease?(self.isChecked)
            })
        
        self.refresh()
    }
    
    @discardableResult
    func setOnRelease(_ callback: ((_ isChecked: Bool) -> Void)?) -> Self {
        self.onRelease = callback
        return self
    }
    
    @discardableResult
    func setState(checked: Bool, trigger: Bool = false) -> Self {
        self.isChecked = checked
        self.refresh()
        if trigger {
            self.onRelease?(self.isChecked)
        }
        return self
    }
    
    @discardableResult
    func setColor(checked: UIColor, unchecked: UIColor) -> Self {
        self.checkedColor = checked
        self.uncheckedColor = unchecked
        self.refresh()
        return self
    }
    
    @discardableResult
    func setIcon(to imageName: String) -> Self {
        if let image = UIImage(named: imageName) {
            self.icon.setImage(image)
        } else if let image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)) {
            self.icon.setImage(image)
        }
        self.refresh()
        return self
    }
    
    @discardableResult
    func setIconColor(to color: UIColor) -> Self {
        self.iconColor = color
        self.refresh()
        return self
    }
    
    @discardableResult
    func isDisabled(_ isDisabled: Bool) -> Self {
        self.control.setDisabled(to: isDisabled)
        return self
    }
    
    private func refresh() {
        if self.isChecked {
            self.container.removeBorder()
            self.container.setBackgroundColor(to: self.checkedColor)
            self.icon.setHidden(to: false)
            self.icon.setColor(to: self.iconColor)
        } else {
            self.container.addBorder(width: Self.BORDER_WIDTH, color: self.uncheckedColor)
            self.container.setBackgroundColor(to: .clear)
            self.icon.setHidden(to: true)
        }
    }
    
}
