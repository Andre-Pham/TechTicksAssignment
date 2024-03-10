//
//  TaskListSectionHeaderReusableView.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

class TaskListSectionHeaderReusableView: UICollectionReusableView {

    public static let REUSE_IDENTIFIER = UUID().uuidString
    public static let ELEMENT_KIND = UUID().uuidString
    public let sectionHeader = TaskListSectionHeaderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.sectionHeader.view)
        self.sectionHeader.constrainAllSides()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
