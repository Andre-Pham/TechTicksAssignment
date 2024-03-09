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
    
    private var saveButtonActive: Bool {
        return self.saveButton.superView != nil
    }
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
            .addGap(size: 20)
        
        self.header
            .constrainLeft()
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
            .setText(to: "New Task")
        
        self.titleEntry
            .constrainHorizontal()
            .setLabel(to: Strings("label.taskName").local)
            .setOnEdit({
                self.updateSaveButton()
            })
        
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
            .setDate(to: self.getDefaultStartDate())
            .setOnDatePicked({ date in
                if self.endDatePicker.date < date {
                    // If the end date is before the start date, it's invalid
                    // We can update it automatically - by default, we'll set it to +1 hour
                    let calendar = Calendar.current
                    if let newEndDate = calendar.date(byAdding: .hour, value: 1, to: date) {
                        self.endDatePicker.setDate(to: newEndDate)
                    }
                }
                self.updateSaveButton()
            })
        
        self.endDateLabel
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.toDate").local)
        
        self.endDatePicker
            .setDate(to: self.getDefaultEndDate())
            .setOnDatePicked({ date in
                self.updateSaveButton()
            })
        
        self.saveButton
            .setColor(to: TickColors.primaryComponentFill)
            .setLabel(to: "Save")
            .setFont(to: TickFont(font: TickFonts.Poppins.Bold, size: 18), color: TickColors.textPrimaryComponent)
            .setOnTap({
                if let task = self.createTaskFromInputs() {
                    self.databaseController?.writeTask(task)
                    self.dismiss(animated: true)
                }
            })
        
        // If the user taps anywhere on-screen, cancel the keyboard
        // Note the keyboard dismissal callback triggers first, then the tap
        // E.g. if you press a button while the keyboard is open, the keyboard closes, then the button press is triggered
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onScreenTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func onScreenTap() {
        self.view.endEditing(true)
    }
    
    private func getDefaultStartDate() -> Date {
        // Get the current date time rounded to the nearest 30 minutes
        return Date().roundedToFuture(to: .minute, nearest: 30) ?? Date()
    }
    
    private func getDefaultEndDate() -> Date {
        let start = self.getDefaultStartDate()
        // By default, tasks will last from now to 1h in the future
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: 1, to: start) ?? start
    }
    
    private func updateSaveButton() {
        if self.createTaskFromInputs() != nil && !self.saveButtonActive {
            self.addSaveButton()
        } else if self.createTaskFromInputs() == nil && self.saveButtonActive {
            self.removeSaveButton()
        }
    }
    
    private func addSaveButton() {
        self.scrollStack.insertView(self.saveButton, at: self.scrollStack.viewCount)
        self.saveButton.constrainHorizontal()
        self.saveButton.animateEntrance(onCompletion: {
            self.scroll.scrollToBottomAnimated()
        })
    }
    
    private func removeSaveButton() {
        self.saveButton.animateExit() {
            self.saveButton.removeFromSuperView()
            self.scroll.layoutIfNeededAnimated()
        }
    }
    
    private func createTaskFromInputs() -> Task? {
        // Read the entries
        let title = self.titleEntry.text
        let description = self.descriptionEntry.text
        let start = self.startDatePicker.date
        let end = self.endDatePicker.date
        // 1. The task must at least have a title
        guard !title.isEmpty else {
            return nil
        }
        // 2. The description is allowed to be empty
        // 3. The end date must be after the start date
        guard end > start else {
            return nil
        }
        let ongoingDuration = DateInterval(start: start, end: end)
        // If we've made it here, all the inputs are valid
        return Task(
            title: title,
            description: description,
            ongoingDuration: ongoingDuration,
            markedComplete: false // Tasks are marked incomplete by default
        )
    }
    
}
