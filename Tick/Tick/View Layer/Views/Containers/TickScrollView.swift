//
//  TickScrollView.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TickScrollView: TickUIView {
    
    private let scrollView = UIScrollView()
    public var view: UIView {
        return self.scrollView
    }
    public var viewCount: Int {
        return self.scrollView.subviews.count
    }
    
    override init() {
        super.init()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    func addView(_ view: TickUIView) -> Self {
        self.scrollView.addSubview(view.view)
        return self
    }
    
    @discardableResult
    func addViewAnimated(_ view: TickUIView, position: Int? = nil) -> Self {
        view.setOpacity(to: 0.0)
        view.setHidden(to: true)
        if let position {
            let validatedPosition = min(position, self.viewCount)
            self.scrollView.insertSubview(view.view, at: validatedPosition)
        } else {
            self.scrollView.addSubview(view.view)
        }
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            view.setOpacity(to: 1.0)
            view.setHidden(to: false)
        })
        return self
    }
    
    @discardableResult
    func removeViewAnimated(_ view: TickUIView) -> Self {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut], animations: {
            view.setOpacity(to: 0.0)
            view.setHidden(to: true)
        }) { _ in
            view.removeFromSuperView()
            view.setOpacity(to: 1.0)
            view.setHidden(to: false)
        }
        return self
    }
    
    @discardableResult
    func removeViewAnimated(position: Int) -> Self {
        guard self.viewCount > position else {
            return self
        }
        let view = self.scrollView.subviews[position]
        return self.removeViewAnimated(TickView(view))
    }
    
    @discardableResult
    func addGap(size: Double, position: Int? = nil, animated: Bool = false) -> Self {
        let gapView = TickView()
            .setHeightConstraint(to: size)
        if animated {
            self.addViewAnimated(gapView, position: position)
        } else {
            if let position {
                self.insertView(gapView, at: position)
            } else {
                self.addView(gapView)
            }
        }
        return self
    }
    
    @discardableResult
    func insertView(_ view: TickUIView, at index: Int) -> Self {
        self.scrollView.insertSubview(view.view, at: index)
        return self
    }
    
    @discardableResult
    func setScrollBarVisibility(vertical: Bool? = nil, horizontal: Bool? = nil) -> Self {
        if let vertical {
            self.scrollView.showsVerticalScrollIndicator = vertical
        }
        if let horizontal {
            self.scrollView.showsHorizontalScrollIndicator = horizontal
        }
        return self
    }
    
    @discardableResult
    func setVerticalBounce(to state: Bool) -> Self {
        self.scrollView.alwaysBounceVertical = state
        return self
    }
    
    @discardableResult
    func setHorizontalBounce(to state: Bool) -> Self {
        self.scrollView.alwaysBounceHorizontal = state
        return self
    }
    
    @discardableResult
    func setContentSize(to size: CGSize) -> Self {
        self.scrollView.contentSize = size
        return self
    }
    
    @discardableResult
    func scrollToBottom() -> Self {
        let bottomOffset = CGPoint(
            x: 0,
            y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom
        )
        if bottomOffset.y > 0 {
            self.scrollView.setContentOffset(bottomOffset, animated: false)
        }
        return self
    }
    
    @discardableResult
    func scrollToBottomAnimated(withEasing easingOption: UIView.AnimationOptions = .curveEaseInOut, duration: Double = 0.3) -> Self {
        let bottomOffset = CGPoint(
            x: 0,
            y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom
        )
        if bottomOffset.y > 0 {
            UIView.animate(withDuration: duration, delay: 0, options: easingOption, animations: {
                self.scrollView.contentOffset = bottomOffset
            }, completion: nil)
        }
        return self
    }
    
}
