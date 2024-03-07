//
//  TickChipMultiState.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TickChipMultiState<T: Any>: TickUIView {
    
    private let container = TickView()
    private let button = TickControl()
    private let contentStack = TickHStack()
    private let imageView = TickImage()
    public let label = TickText()
    private(set) var values = [T]()
    private var labels = [String]()
    private var icons = [UIImage]()
    private(set) var stateIndex = 0
    private var onChange: ((_ value: T) -> Void)? = nil
    private var foregroundColor = TickColors.textSecondaryComponent
    public var view: UIView {
        return self.container.view
    }
    public var activeValue: T {
        return self.values[self.stateIndex]
    }
    private var activeLabel: String? {
        guard self.labels.count - 1 >= self.stateIndex else {
            return nil
        }
        return self.labels[self.stateIndex]
    }
    private var activeIcon: UIImage? {
        guard self.icons.count - 1 >= self.stateIndex else {
            return nil
        }
        return self.icons[self.stateIndex]
    }
    
    override init() {
        super.init()
        
        self.container
            .setHeightConstraint(to: TickDimensions.chipHeight)
            .setBackgroundColor(to: TickColors.secondaryComponentFill)
            .setCornerRadius(to: TickDimensions.foregroundCornerRadius)
            .addSubview(self.contentStack)
            .addSubview(self.button)
        
        self.contentStack
            .constrainVertical()
            .constrainHorizontal(padding: TickDimensions.chipPaddingHorizontal)
            .setSpacing(to: 10)
            .addView(self.imageView)
            .addView(self.label)
        
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
            .setWidthConstraint(to: 30)
            .setColor(to: TickColors.textSecondaryComponent)
        
        self.label
            .setFont(to: TickFont(font: TickFonts.Quicksand.SemiBold, size: 20))
            .setTextAlignment(to: .center)
    }
    
    private func refresh() {
        if let icon = self.activeIcon {
            self.imageView.setImage(icon)
        }
        if let label = self.activeLabel {
            self.label.setText(to: label)
        }
        self.imageView.setColor(to: self.foregroundColor)
        self.label.setTextColor(to: self.foregroundColor)
    }
    
    @discardableResult
    func setFixedWidth(width: Double) -> Self {
        self.container.setWidthConstraint(to: width)
        self.contentStack.view.removeConstraints(self.contentStack.view.constraints)
        self.contentStack.constrainVertical()
        return self
    }
    
    @discardableResult
    func setState(state: Int, trigger: Bool = false) -> Self {
        self.stateIndex = state
        self.refresh()
        if trigger {
            self.onChange?(self.activeValue)
        }
        return self
    }
    
    @discardableResult
    func addState(value: T, label: String? = nil, icon: String? = nil) -> Self {
        assert(!(label == nil && icon == nil), "Label and icon can't simultaneously be nil for this")
        self.values.append(value)
        if let label {
            self.labels.append(label)
        }
        if let icon {
            if let image = UIImage(named: icon) {
                self.icons.append(image)
            } else if let image = UIImage(systemName: icon) {
                self.icons.append(image)
            } else {
                assertionFailure("Invalid icon provided")
                self.icons.append(UIImage(systemName: "questionmark.circle.fill")!)
            }
        }
        // If we've added state but there's no labels/icons, we assume there are none to come
        if self.labels.isEmpty {
            self.label.removeFromSuperView()
        }
        if self.icons.isEmpty {
            self.imageView.removeFromSuperView()
        }
        self.refresh()
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.container.setBackgroundColor(to: color)
        return self
    }
    
    @discardableResult
    func setForegroundColor(to color: UIColor) -> Self {
        self.foregroundColor = color
        self.refresh()
        return self
    }
    
    @discardableResult
    func setOnChange(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onChange = callback
        return self
    }
    
    private func onTapCallback() {
        self.stateIndex = (self.stateIndex + 1)%self.values.count
        self.refresh()
        self.onChange?(self.activeValue)
    }
    
}

