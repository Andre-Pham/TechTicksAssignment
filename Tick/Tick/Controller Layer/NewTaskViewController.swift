//
//  NewTaskViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class NewTaskViewController: UIViewController {
    
    private var root: TickView { return TickView(self.view) }
    private let scroll = TickScrollView()
    private let scrollStack = TickVStack()
    private let header = TickText()
    private let titleEntry = TickLabelledTextInput()
    private let descriptionEntry = TickLabelledTextInput()
    private let dateStack = TickVStack()
    private let startDateStack = TickHStack()
    private let startDateLabel = TickText()
    private let startDatePicker = TickDatePicker()
    private let endDateStack = TickHStack()
    private let endDateLabel = TickText()
    private let endDatePicker = TickDatePicker()
    private let saveButton = TickButton()
    
    weak var databaseController: LocalDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.databaseController = appDelegate?.databaseController
        
        self.root
            .setBackgroundColor(to: TickColors.foregroundFill)
            .addSubview(self.scroll)
        
        self.scroll
            .constrainAllSides()
            .setVerticalBounce(to: true)
            .addView(self.scrollStack)
        
        self.scrollStack
            .constrainHorizontal(padding: TickDimensions.screenContentPaddingHorizontal)
            .constrainTop(padding: TickDimensions.screenContentPaddingVertical, toContentLayoutGuide: true)
            .constrainBottom(respectSafeArea: false, toContentLayoutGuide: true)
            .setSpacing(to: 20)
            .addView(self.header)
            .addView(self.titleEntry)
            .addView(self.descriptionEntry)
            .addView(self.dateStack)
            .addView(self.saveButton)
        
        self.header
            .constrainLeft()
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
            .setText(to: "New Task")
        
        self.titleEntry
            .constrainHorizontal()
            .setLabel(to: Strings("label.taskName").local)
        
        self.descriptionEntry
            .constrainHorizontal()
            .setLabel(to: Strings("label.taskDescription").local)
        
        self.dateStack
            .constrainHorizontal()
            .setSpacing(to: 4)
            .addView(self.startDateStack)
            .addView(self.endDateStack)
        
        self.startDateStack
            .constrainHorizontal()
            .setSpacing(to: 16)
            .addView(self.startDateLabel)
            .addView(self.startDatePicker)
        
        self.endDateStack
            .constrainHorizontal()
            .setSpacing(to: 16)
            .addView(self.endDateLabel)
            .addView(self.endDatePicker)
        
        self.startDateLabel
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.fromDate").local)
        
        self.startDatePicker
            .setOnDatePicked({ date in
                print("Start date picked")
            })
        
        self.endDateLabel
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.toDate").local)
        
        self.endDatePicker
            .setOnDatePicked({ date in
                print("End date picked")
            })
        
        self.saveButton
            .constrainHorizontal()
            .setColor(to: TickColors.primaryComponentFill)
            .setLabel(to: "Save")
            .setFont(to: TickFont(font: TickFonts.Poppins.Bold, size: 18), color: TickColors.textPrimaryComponent)
            .setOnTap({
                self.databaseController?.writeTask(Task(
                    title: self.titleEntry.text,
                    description: self.descriptionEntry.text,
                    ongoingDuration: DateInterval(start: Date(), end: Date()), // TODO: Fix
                    markedComplete: false
                ))
                // TODO: Rework save changes
//                self.databaseController?.saveChanges()
            })
    }
    
}
