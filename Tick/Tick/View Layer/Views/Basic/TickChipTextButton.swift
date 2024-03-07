//
//  TickChipTextButton.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TickChipTextButton: TickUIView {
    
    private let container = TickView()
    private let contentStack = TickHStack()
    private let button = TickControl()
    private let imageView = TickImage()
    private let label = TickText()
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.container.view
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
            .setWidthConstraint(to: 26)
            .setColor(to: TickColors.textSecondaryComponent)
        
        self.label
            .setFont(to: TickFont(font: TickFonts.Quicksand.SemiBold, size: 20))
            .setTextAlignment(to: .center)
    }
    
    @discardableResult
    func setIconWidth(to width: Double) -> Self {
        self.imageView
            .removeWidthConstraint()
            .setWidthConstraint(to: width)
        return self
    }
    
    @discardableResult
    func setIcon(to icon: String) -> Self {
        if let image = UIImage(named: icon) {
            self.imageView.setImage(image)
        } else if let image = UIImage(systemName: icon) {
            self.imageView.setImage(image)
        }
        return self
    }
    
    @discardableResult
    func setLabel(to label: String) -> Self {
        self.label.setText(to: label)
        return self
    }
    
    @discardableResult
    func setLabelSize(to size: CGFloat) -> Self {
        self.label.setSize(to: size)
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.container.setBackgroundColor(to: color)
        return self
    }
    
    @discardableResult
    func setIconColor(to color: UIColor) -> Self {
        self.imageView.setColor(to: color)
        self.label.setTextColor(to: color)
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    private func onTapCallback() {
        self.onTap?()
    }
    
}
