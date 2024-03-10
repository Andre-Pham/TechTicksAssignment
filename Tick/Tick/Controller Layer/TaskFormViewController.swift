//
//  TaskFormViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import Foundation
import UIKit

class TaskFormViewController: UIViewController {
    
    private var root: TickView { return TickView(self.view) }
    private let scroll = TickScrollView()
    private let scrollStack = TickVStack()
    private let headerSection = TickVStack()
    private let header = TickText()
    private let statusStack = TickHStack()
    private let statusPrefix = TickText()
    private let statusIndicator = TickText()
    private let titleEntry = TickLabelledTextInput()
    private let descriptionEntry = TickLabelledTextInput()
    private let dateStack = TickVStack()
    private let startDateStack = TickHStack()
    private let startDateLabel = TickText()
    private let startDatePicker = TickDatePicker()
    private let endDateStack = TickHStack()
    private let endDateLabel = TickText()
    private let endDatePicker = TickDatePicker()
    private let preCompletedStack = TickHStack()
    private let preCompletedLabel = TickText()
    private let preCompletedCheckBox = CheckBoxView()
    private let buttonStack = TickHStack()
    private let saveButton = TickButton()
    private let revertButton = TickButton()
    
    private var taskInEditing: Task? = nil
    private var inEditMode: Bool {
        return self.taskInEditing != nil
    }
    private var saveButtonActive: Bool {
        return self.saveButton.hasSuperView && self.buttonStackActive
    }
    private var buttonStackActive: Bool {
        return self.buttonStack.hasSuperView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            .addView(self.headerSection)
            .addView(self.titleEntry)
            .addView(self.descriptionEntry)
            .addView(self.dateStack)
            .addView(self.preCompletedStack)
            .addGap(size: 20)
        
        self.headerSection
            .constrainHorizontal()
            .addView(self.header)
            .addView(self.statusStack)
        
        self.header
            .constrainLeft()
            .setFont(to: TickFont(font: TickFonts.Inter.Black, size: 48))
            .setText(to: self.inEditMode ? Strings("header.editTask").local : Strings("header.newTask").local)
        
        self.statusStack
            .constrainLeft()
            .addView(self.statusPrefix)
            .addView(self.statusIndicator)
            .addSpacer()
        
        self.statusPrefix
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.taskStatus").local + ": ")
        
        self.statusIndicator
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
        
        self.titleEntry
            .setAccessibilityIdentifier(to: "TITLE_ENTRY")
            .constrainHorizontal()
            .setLabel(to: Strings("label.taskName").local)
            .setOnEdit({
                self.updateTaskStatusIndicator()
                self.updateButtonStack()
            })
        
        self.descriptionEntry
            .setAccessibilityIdentifier(to: "DESCRIPTION_ENTRY")
            .constrainHorizontal()
            .setLabel(to: Strings("label.taskDescription").local)
            .setOnEdit({
                self.updateTaskStatusIndicator()
                self.updateButtonStack()
            })
        
        self.dateStack
            .constrainHorizontal()
            .setSpacing(to: 4)
            .addView(self.startDateStack)
            .addView(self.endDateStack)
        
        self.preCompletedStack
            .constrainHorizontal()
            .addView(self.preCompletedLabel)
            .addSpacer()
            .addView(self.preCompletedCheckBox)
        
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
            .setText(to: Strings("label.fromDate").local + ":")
        
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
                self.updateTaskStatusIndicator()
                self.updateButtonStack()
            })
        
        self.endDateLabel
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.toDate").local + ":")
        
        self.endDatePicker
            .setDate(to: self.getDefaultEndDate())
            .setOnDatePicked({ date in
                self.updateTaskStatusIndicator()
                self.updateButtonStack()
            })
        
        self.preCompletedLabel
            .setFont(to: TickFont(font: TickFonts.Poppins.Medium, size: 14))
            .setTextColor(to: TickColors.textDark2)
            .setText(to: Strings("label.alreadyCompleted").local + ":")
        
        self.preCompletedCheckBox
            .setColor(checked: TickColors.completedTask, unchecked: TickColors.textDark2)
            .setIcon(to: "checkmark")
            .setOnRelease({ isChecked in
                self.updateTaskStatusIndicator()
                self.updateButtonStack()
            })
        
        self.buttonStack
            .setDistribution(to: .fillEqually)
            .setSpacing(to: 20)
        if self.inEditMode {
            self.buttonStack.addView(self.revertButton)
        }
        self.buttonStack.addView(self.saveButton)
        
        if self.inEditMode {
            self.revertButton
                .setColor(to: TickColors.secondaryComponentFill)
                .setLabel(to: Strings("button.revert").local)
                .setFont(to: TickFont(font: TickFonts.Poppins.Bold, size: 18), color: TickColors.textSecondaryComponent)
                .setOnTap({
                    self.matchEntriesToTaskInEditing()
                    self.updateTaskStatusIndicator()
                    self.updateButtonStack()
                })
        }
        
        self.saveButton
            .setAccessibilityIdentifier(to: "SAVE_TASK_BUTTON")
            .setColor(to: TickColors.primaryComponentFill)
            .setLabel(to: Strings("button.save").local)
            .setFont(to: TickFont(font: TickFonts.Poppins.Bold, size: 18), color: TickColors.textPrimaryComponent)
            .setOnTap({
                if let task = self.createTaskFromInputs() {
                    if self.inEditMode {
                        Session.inst.editTaskContent(task)
                    } else {
                        Session.inst.createTask(task)
                    }
                    self.dismiss(animated: true)
                }
            })
        
        self.updateTaskStatusIndicator()
        
        // If the user taps anywhere on-screen, cancel the keyboard
        // Note the keyboard dismissal callback triggers first, then the tap
        // E.g. if you press a button while the keyboard is open, the keyboard closes, then the button press is triggered
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onScreenTap))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func setToEdit(task: Task) {
        self.taskInEditing = task
        self.matchEntriesToTaskInEditing()
    }
    
    @objc private func onScreenTap() {
        self.view.endEditing(true)
    }
    
    private func getDefaultStartDate() -> Date {
        if let taskInEditing {
            return taskInEditing.ongoingDuration.start
        }
        // Get the current date time rounded to the nearest 30 minutes
        return Date().roundedToFuture(to: .minute, nearest: 30) ?? Date()
    }
    
    private func getDefaultEndDate() -> Date {
        if let taskInEditing {
            return taskInEditing.ongoingDuration.end
        }
        let start = self.getDefaultStartDate()
        // By default, tasks will last from now to 1h in the future
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: 1, to: start) ?? start
    }
    
    private func updateTaskStatusIndicator() {
        if let task = self.createTaskFromInputs() {
            switch task.status {
            case .upcoming:
                self.statusIndicator
                    .setText(to: Strings("taskStatus.upcoming").local.uppercased())
                    .setTextColor(to: TickColors.upcomingTask)
            case .ongoing:
                self.statusIndicator
                    .setText(to: Strings("taskStatus.ongoing").local.uppercased())
                    .setTextColor(to: TickColors.ongoingTask)
            case .completed:
                self.statusIndicator
                    .setText(to: Strings("taskStatus.completed").local.uppercased())
                    .setTextColor(to: TickColors.completedTask)
            }
        } else {
            self.statusIndicator
                .setText(to: Strings("label.invalid").local.uppercased())
                .setTextColor(to: TickColors.warning)
        }
    }
    
    private func updateButtonStack() {
        if self.inEditMode {
            let modifiedTask = self.createTaskFromInputs()
            if let modifiedTask, !modifiedTask.dataMatches(task: self.taskInEditing!) {
                self.addSaveButton()
                self.addButtonStack()
            } else {
                if let modifiedTask, modifiedTask.dataMatches(task: self.taskInEditing!) {
                    self.removeButtonStack()
                } else if modifiedTask == nil {
                    self.addButtonStack(removeSaveButton: true)
                    self.removeSaveButton()
                }
            }
        } else {
            if self.createTaskFromInputs() != nil {
                self.addButtonStack()
            } else if self.createTaskFromInputs() == nil {
                self.removeButtonStack()
            }
        }
    }
    
    private func addButtonStack(removeSaveButton: Bool = false) {
        guard !self.buttonStackActive else {
            return
        }
        self.scrollStack.insertView(self.buttonStack, at: self.scrollStack.viewCount)
        self.buttonStack.constrainHorizontal()
        if removeSaveButton && self.saveButtonActive {
            self.saveButton.removeFromSuperView()
        }
        self.buttonStack.animateEntrance(onCompletion: {
            self.scroll.scrollToBottomAnimated()
        })
    }
    
    private func removeButtonStack() {
        guard self.buttonStackActive else {
            return
        }
        self.buttonStack.animateExit() {
            self.buttonStack.removeFromSuperView()
            self.scroll.layoutIfNeededAnimated()
        }
    }
    
    private func addSaveButton() {
        guard !self.saveButtonActive else {
            return
        }
        self.buttonStack.addViewAnimated(self.saveButton)
    }
    
    private func removeSaveButton() {
        guard self.saveButtonActive else {
            return
        }
        self.buttonStack.removeViewAnimated(self.saveButton)
    }
    
    private func createTaskFromInputs() -> Task? {
        // Read the entries
        let title = self.titleEntry.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = self.descriptionEntry.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let start = self.startDatePicker.date
        let end = self.endDatePicker.date
        let isCompleted = self.preCompletedCheckBox.isChecked
        // 1. The task must at least have a title
        guard !title.isEmpty else {
            return nil
        }
        // 2. The description is allowed to be empty
        // 3. The end date must be after the start date
        guard end > start else {
            return nil
        }
        // 4. The task can't in the future AND completed already - only ongoing tasks can be completed
        if start > Date() && isCompleted {
            return nil
        }
        let ongoingDuration = DateInterval(start: start, end: end)
        // If we've made it here, all the inputs are valid
        return Task(
            id: self.taskInEditing?.id ?? UUID(),
            title: title,
            description: description,
            ongoingDuration: ongoingDuration,
            markedComplete: isCompleted
        )
    }
    
    private func matchEntriesToTaskInEditing() {
        guard let task = self.taskInEditing else {
            assertionFailure("This shouldn't be called unless a task in editing is defined")
            return
        }
        self.titleEntry.setText(to: task.title)
        self.descriptionEntry.setText(to: task.description)
        self.startDatePicker.setDate(to: task.ongoingDuration.start)
        self.endDatePicker.setDate(to: task.ongoingDuration.end)
        self.preCompletedCheckBox.setState(checked: task.markedComplete)
    }
    
}
