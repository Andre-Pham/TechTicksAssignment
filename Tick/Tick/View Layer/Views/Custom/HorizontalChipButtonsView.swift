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
    func addChip(value: T, label: String) -> Self {
        let container = TickView()
        let text = TickText()
        let control = TickControl()
        container
            .setHeightConstraint(to: Self.CHIP_HEIGHT)
            .setCornerRadius(to: Self.CHIP_HEIGHT/2.0)
            .setBackgroundColor(to: TickColors.blackPermanent)
            .addSubview(text)
            .addSubview(control)
        text
            .constrainVertical(padding: Self.CHIP_VERTICAL_INNER_PADDING)
            .constrainHorizontal(padding: Self.CHIP_HORIZONTAL_INNER_PADDING)
            .setText(to: label)
            .setFont(to: TickFont(font: TickFonts.IBMPlexMono.Bold, size: 14))
            .setTextColor(to: TickColors.whitePermanent)
        control
            .constrainAllSides()
            .setOnPress({
                self.onTap?(value)
            })
        self.controls.append(control)
        self.stack.addView(container)
        self.cumulativeWidth += text.intrinsicContentSize.width + Self.CHIP_HORIZONTAL_INNER_PADDING*2.0
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
