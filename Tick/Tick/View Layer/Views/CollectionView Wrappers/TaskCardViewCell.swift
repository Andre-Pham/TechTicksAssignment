//
//  TaskCardViewCell.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

class TaskCardViewCell: UICollectionViewCell {

    public static let REUSE_IDENTIFIER = UUID().uuidString
    public let card = TaskCardView()
    
    lazy var width: NSLayoutConstraint = {
        let width = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        width.isActive = true
        return width
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.card.view)
        self.card.constrainAllSides()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
