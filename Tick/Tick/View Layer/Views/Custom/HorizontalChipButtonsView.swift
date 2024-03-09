//
//  HorizontalChipButtonsView.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

class HorizontalChipButtonsView<T>: TickUIView {
    
    private static var CHIP_HEIGHT: Double { 40.0 }
    private static var CHIP_SPACING: Double { 8.0 }
    private static var CHIP_VERTICAL_INNER_PADDING: Double { 8.0 }
    private static var CHIP_HORIZONTAL_INNER_PADDING: Double { 16.0 }
    
    private let scroll = TickScrollView()
    private let stack = TickHStack()
    private var chips = [ChipButton]()
    /// The controls that respond to taps - must be stored to maintain a reference, otherwise the callback doesn't trigger
    private var controls = [TickControl]()
    private var cumulativeWidth = 0.0
    private var onTap: ((_ value: T) -> Void)? = nil
    private var contentSize: CGSize {
        return CGSize(width: self.cumulativeWidth, height: Self.CHIP_HEIGHT)
    }
    public var view: UIView {
        return self.scroll.view
    }
    
    override init() {
        super.init()
        
        self.scroll
            .setHorizontalBounce(to: true)
            .addView(self.stack)
            .setScrollBarVisibility(horizontal: false)
            .setClipsToBounds(to: false)
        
        self.stack
            .constrainVertical()
            .setSpacing(to: Self.CHIP_SPACING)
    }
    
    @discardableResult
    func addChip(value: T, label: String, color: UIColor, textColor: UIColor, selected: Bool = false) -> Self {
        let chip = ChipButton()
        chip.color = color
        chip.textColor = textColor
        chip.container
            .setHeightConstraint(to: Self.CHIP_HEIGHT)
            .setCornerRadius(to: Self.CHIP_HEIGHT/2.0)
            .setBackgroundColor(to: TickColors.blackPermanent)
        chip.text
            .constrainVertical(padding: Self.CHIP_VERTICAL_INNER_PADDING)
            .constrainHorizontal(padding: Self.CHIP_HORIZONTAL_INNER_PADDING)
            .setText(to: label)
            .setFont(to: TickFont(font: TickFonts.IBMPlexMono.Bold, size: 14))
            .setTextColor(to: TickColors.whitePermanent)
        chip.control
            .constrainAllSides()
            .setOnPress({
                for chip in self.chips {
                    chip.refresh(selected: false)
                }
                chip.refresh(selected: true)
                self.onTap?(value)
            })
        chip.refresh(selected: selected)
        self.chips.append(chip)
        self.controls.append(chip.control)
        self.stack.addView(chip)
        self.cumulativeWidth += chip.text.intrinsicContentSize.width + Self.CHIP_HORIZONTAL_INNER_PADDING*2.0
        if self.controls.count > 1 {
            self.cumulativeWidth += Self.CHIP_SPACING
        }
        self.scroll.setContentSize(to: self.contentSize)
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: ((_ value: T) -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
}

fileprivate class ChipButton: TickUIView {
    
    public let container = TickView()
    public let text = TickText()
    public let control = TickControl()
    public var color = TickColors.blackPermanent
    public var textColor = TickColors.whitePermanent
    public var view: UIView {
        return self.container.view
    }
    
    override init() {
        super.init()
        
        self.container
            .addSubview(self.text)
            .addSubview(self.control)
    }
    
    public func refresh(selected: Bool) {
        if selected {
            self.container
                .setBackgroundColor(to: self.color)
                .removeBorder()
            self.text.setTextColor(to: self.textColor)
        } else {
            self.container
                .setBackgroundColor(to: .clear)
                .addBorder(width: 2.0, color: self.color)
            self.text.setTextColor(to: self.color)
        }
    }
    
}
