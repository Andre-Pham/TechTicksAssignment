//
//  TickChipToggle.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TickChipToggle: TickUIView {
    
    private let container = TickView()
    private let button = TickControl()
    private let imageView = TickImage()
    private var activatedIcon: UIImage? = nil
    private var deactivatedIcon: UIImage? = nil
    private var deactivatedColor = TickColors.secondaryComponentFill
    private var activatedColor = TickColors.primaryComponentFill
    private var deactivatedIconColor = TickColors.textSecondaryComponent
    private var activatedIconColor = TickColors.textPrimaryComponent
    private(set) var isActivated = false
    private var onTap: ((_ isEnabled: Bool) -> Void)? = nil
    public var isDisabled: Bool {
        return self.button.isDisabled
    }
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .setWidthConstraint(to: TickDimensions.chipWidth)
            .setHeightConstraint(to: TickDimensions.chipHeight)
            .setBackgroundColor(to: self.deactivatedColor)
            .setCornerRadius(to: TickDimensions.foregroundCornerRadius)
            .addSubview(self.button)
            .addSubview(self.imageView)
        
        self.button
            .constrainAllSides()
            .setOnPress({
                self.container.animatePressedOpacity()
            })
            .setOnRelease({
                self.onTapCallback()
                self.container.animateReleaseOpacity()
            })
        
        self.imageView
            .constrainHorizontal(padding: TickDimensions.chipPaddingHorizontal)
            .constrainVertical(padding: TickDimensions.chipPaddingVertical)
            .setColor(to: self.deactivatedIconColor)
    }
    
    private func refresh() {
        self.container.setBackgroundColor(to: self.isActivated ? self.activatedColor : self.deactivatedColor)
        self.imageView.setColor(to: self.isActivated ? self.activatedIconColor : self.deactivatedIconColor)
        if let newImage = self.isActivated ? self.activatedIcon : self.deactivatedIcon {
            self.imageView.setImage(newImage)
        }
    }
    
    @discardableResult
    func setState(activated: Bool, trigger: Bool = false) -> Self {
        self.isActivated = activated
        self.refresh()
        if trigger {
            self.onTap?(self.isActivated)
        }
        return self
    }
    
    @discardableResult
    func setIcon(to activated: String, deactivated: String? = nil) -> Self {
        if let image = UIImage(named: activated) {
            self.activatedIcon = image
        } else if let image = UIImage(systemName: activated) {
            self.activatedIcon = image
        }
        if let deactivated {
            if let image = UIImage(named: deactivated) {
                self.deactivatedIcon = image
            } else if let image = UIImage(systemName: deactivated) {
                self.deactivatedIcon = image
            }
        } else {
            self.deactivatedIcon = self.activatedIcon
        }
        self.refresh()
        return self
    }
    
    @discardableResult
    func setColor(activated: UIColor, deactivated: UIColor) -> Self {
        self.activatedColor = activated
        self.deactivatedColor = deactivated
        self.refresh()
        return self
    }
    
    @discardableResult
    func setIconColor(activated: UIColor, deactivated: UIColor) -> Self {
        self.activatedIconColor = activated
        self.deactivatedIconColor = deactivated
        self.refresh()
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: ((_ isEnabled: Bool) -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    @discardableResult
    func setDisabled(to state: Bool) -> Self {
        self.button.setDisabled(to: state)
        return self
    }
    
    private func onTapCallback() {
        self.isActivated.toggle()
        self.refresh()
        self.onTap?(self.isActivated)
    }
    
}
