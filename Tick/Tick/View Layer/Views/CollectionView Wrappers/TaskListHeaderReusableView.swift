//
//  TaskListHeaderReusableView.swift
//  Tick
//
//  Created by Andre Pham on 10/3/2024.
//

import Foundation
import UIKit

class TaskListHeaderReusableView: UICollectionReusableView {
    
    public static let REUSE_IDENTIFIER = UUID().uuidString
    public static let ELEMENT_KIND = UUID().uuidString
    public let header = TaskListHeaderView<TaskStatus?>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.header.view)
        self.header.constrainAllSides()
        self.header.filterControls
            .addChip(
                value: nil,
                label: Strings("filter.all").local.capitalized,
                color: TickColors.textDark2,
                textColor: TickColors.white,
                selected: true
            )
            .addChip(
                value: .ongoing,
                label: Strings("taskStatus.ongoing").local.capitalized,
                color: TickColors.textDark2,
                textColor: TickColors.white
            )
            .addChip(
                value: .upcoming,
                label: Strings("taskStatus.upcoming").local.capitalized,
                color: TickColors.textDark2,
                textColor: TickColors.white
            )
            .addChip(
                value: .completed,
                label: Strings("taskStatus.completed").local.capitalized,
                color: TickColors.textDark2,
                textColor: TickColors.white
            )
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
