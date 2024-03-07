//
//  TickButton.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TickButton: TickUIView {
    
    private let button = UIButton(type: .custom)
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.button
    }
    public var color: UIColor? {
        return self.button.tintColor
    }
    private var newConfig: UIButton.Configuration {
        return UIButton.Configuration.filled()
    }
    
    override init() {
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = TickDimensions.foregroundCornerRadius
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 22,
            bottom: 10,
            trailing: 22
        )
        self.button.configuration = config
        self.button.addTarget(self, action: #selector(self.onTapCallback), for: .touchUpInside)
    }
    
    @discardableResult
    func setLabel(to label: String) -> Self {
        var config = self.button.configuration ?? self.newConfig
        config.title = label
        self.button.configuration = config
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.button.tintColor = color
        return self
    }
    
    @discardableResult
    func setAccessibilityLabel(to label: String) -> Self {
        self.button.accessibilityLabel = label
        return self
    }
    
    @discardableResult
    func setFont(to font: UIFont, color: UIColor) -> Self {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedString = NSAttributedString(string: self.button.configuration?.title ?? "", attributes: attributes)
        self.button.setAttributedTitle(attributedString, for: .normal)
        return self
    }
    
    @discardableResult
    func isDisabled(_ isDisabled: Bool) -> Self {
        self.button.isEnabled = !isDisabled
        return self
    }
    
    @objc private func onTapCallback() {
        self.onTap?()
    }
    
}
