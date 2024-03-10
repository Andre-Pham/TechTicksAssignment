//
//  TasksCollectionViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

/// View controller for the collection of tasks the user creates, views, and interacts with.
class TasksCollectionViewController: UICollectionViewController, DatabaseListener {
    
    // MARK: - Constants
    
    private static let TASK_CARD_SPACING = 12.0
    private static let SECTION_PADDING_TOP = 0.0
    private static let SECTION_PADDING_BOTTOM = 14.0
    private static let SECTION_PADDING_LEFT = 14.0
    private static let SECTION_PADDING_RIGHT = 14.0
    private static let SECTION_HEADER_HEIGHT = 36.0
    private static let HEADER_HEIGHT = 130.0
    
    // MARK: - Properties
    
    /// The root view
    private var root: TickView { return TickView(self.view) }
    /// An filled overlay over the top safe area so views don't interfere
    private let safeAreaOverlay = TickView()
    
    /// Monitors minutes - triggers a callback at the start of every new minute
    private let minuteMonitor = MinuteMonitor()
    /// A data structure for storing, organising, and retrieving tasks
    private var taskCollection = TaskCollection()
    /// The sections (of tasks) being rendered
    private var activeSections: [TaskStatus] = [.ongoing, .upcoming, .completed]
    /// The diffable data source - allows for the creation, configuration, tracking, and animation of cells and supplementary views in the collection view
    private var taskListDataSource: UICollectionViewDiffableDataSource<TaskStatus, Task.ID>!
    /// What types of databsae callbacks this is interested in - conforms to DatabaseListener protocol
    public var listenerType = DatabaseListenerType.task
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set everything up - render tasks saved to persistent memory
        self.setupViews()
        self.configureCollectionView()
        self.configureDataSource()
        self.loadTaskData()
        
        // Setup the callback to trigger at the beginning of every minute
        // Every minute, we check if there's any tasks that have a start time equal to the current time (to the minute)
        // If there are tasks that do, we reload and re-render them - they belong to new sections now
        self.minuteMonitor.startMonitoring {
            let tasksToRedraw = self.taskCollection.getTasks(triggeringAt: Date())
            if !tasksToRedraw.isEmpty {
                // Reload the cells - content within cells (like if they have a check box) needs to be re-rendered when changing sections
                self.collectionView.reloadData()
                // Animate the cells moving between sections
                self.refreshTaskList()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Session.inst.listenToDatabase(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Session.inst.endListenToDatabase(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            // If the device is rotating, re-draw the layout to match
            self.collectionView.collectionViewLayout.invalidateLayout()
            // Don't forget about the new safe area height
            self.safeAreaOverlay
                .removeHeightConstraint()
                .setHeightConstraint(to: Environment.inst.topSafeAreaHeight)
        }, completion: nil)
    }
    
    // MARK: - View Setup and Configuration
    
    /// Sets up views that don't belong to the collection view
    private func setupViews() {
        self.root
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(TickView(self.collectionView))
            .addSubview(self.safeAreaOverlay)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        TickView(self.collectionView)
            .setBackgroundColor(to: TickColors.backgroundFill)
            .constrainHorizontal()
            .constrainVertical(respectSafeArea: false)
        
        self.safeAreaOverlay
            .constrainTop(respectSafeArea: false)
            .constrainHorizontal()
            .setHeightConstraint(to: Environment.inst.topSafeAreaHeight)
            .setBackgroundColor(to: TickColors.backgroundFill)
    }
    
    /// Configure the collection view's properties and register cells
    private func configureCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.register(
            TaskCardViewCell.self,
            forCellWithReuseIdentifier: TaskCardViewCell.REUSE_IDENTIFIER
        )
        self.collectionView.register(
            TaskListSectionHeaderReusableView.self,
            forSupplementaryViewOfKind: TaskListSectionHeaderReusableView.ELEMENT_KIND,
            withReuseIdentifier: TaskListSectionHeaderReusableView.REUSE_IDENTIFIER
        )
        self.collectionView.register(
            TaskListHeaderReusableView.self,
            forSupplementaryViewOfKind: TaskListHeaderReusableView.ELEMENT_KIND,
            withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER
        )
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // Define how sections are laid out
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: Self.SECTION_PADDING_TOP,
                leading: Self.SECTION_PADDING_LEFT,
                bottom: Self.SECTION_PADDING_BOTTOM,
                trailing: Self.SECTION_PADDING_RIGHT
            )
            section.interGroupSpacing = Self.TASK_CARD_SPACING
            // Define how section headers are laid out
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Self.SECTION_HEADER_HEIGHT))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: TaskListSectionHeaderReusableView.ELEMENT_KIND,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            if sectionIndex == 0 {
                // Define how the main header is laid out - only rendered at the top (first section index)
                let mainHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Self.HEADER_HEIGHT))
                let mainHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: mainHeaderSize,
                    elementKind: TaskListHeaderReusableView.ELEMENT_KIND,
                    alignment: .top,
                    absoluteOffset: CGPoint(x: 0.0, y: -Self.SECTION_HEADER_HEIGHT)
                )
                section.boundarySupplementaryItems = [mainHeader, sectionHeader]
            } else {
                section.boundarySupplementaryItems = [sectionHeader]
            }
            return section
        }
    }
    
    /// Configure the diffable data source - define how the cells and supplementary views are rendered
    private func configureDataSource() {
        // Setup collection view cells
        let taskCellRegistration = UICollectionView.CellRegistration<TaskCardViewCell, Task> { cell, indexPath, task in
            self.configureTaskCard(cell: cell, task: task)
        }
        self.taskListDataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { [self] collectionView, indexPath, identifier -> UICollectionViewCell in
            let task = self.taskCollection.getTask(id: identifier)
            return self.collectionView.dequeueConfiguredReusableCell(using: taskCellRegistration, for: indexPath, item: task)
        }
        // Setup collection view supplementary views (the headers)
        self.taskListDataSource.supplementaryViewProvider = { (view, kind, indexPath) in
            if kind == TaskListHeaderReusableView.ELEMENT_KIND {
                // This is the header at the very top
                let view = self.collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER,
                    for: indexPath
                ) as! TaskListHeaderReusableView
                self.configureTaskListHeader(view: view, indexPath: indexPath)
                return view
            } else if kind == TaskListSectionHeaderReusableView.ELEMENT_KIND {
                // These are the section headers that represent the task status'
                let view = self.collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TaskListSectionHeaderReusableView.REUSE_IDENTIFIER,
                    for: indexPath
                ) as! TaskListSectionHeaderReusableView
                self.configureTaskListSectionHeader(view: view, indexPath: indexPath)
                return view
            }
            fatalError("Unrecognized element kind passed")
        }
    }
    
    /// Configure how the main header is drawn and its interactions
    /// - Parameters:
    ///   - view: The view to configure
    ///   - indexPath: The index path of the view within the collection view
    private func configureTaskListHeader(view: TaskListHeaderReusableView, indexPath: IndexPath) {
        view.header.setContent(header: Strings("header.tasks").local)
        view.header.newTaskButton
            .setAccessibilityIdentifier(to: "NEW_TASK_BUTTON")
            .setOnTap({
                // Modally open a new view controller
                // By default it allows the creation of a new task
                let newController = TaskFormViewController()
                self.present(newController, animated: true)
            })
        view.header.filterControls
            .setOnTap({ status in
                // The closure parameter (status) defines status what to filter by
                // (E.g. .ongoing -> only show ongoing tasks)
                // If it's nil, show all of them
                let oldSections = self.activeSections
                if let status {
                    self.activeSections = [status]
                } else {
                    self.activeSections = [.ongoing, .upcoming, .completed]
                }
                if oldSections != self.activeSections {
                    // The data doesn't change so we don't need to reload any data
                    // Just refresh the task list cells to show only the relevant (filtered) tasks
                    // No need to animate, there isn't exactly much overlap between filters - it feels snappier without
                    self.refreshTaskList(animate: false)
                }
            })
    }
    
    /// Configure how the section headers are drawn (each represent a task status)
    /// - Parameters:
    ///   - view: The view to configure
    ///   - indexPath: The index path of the view within the collection view
    private func configureTaskListSectionHeader(view: TaskListSectionHeaderReusableView, indexPath: IndexPath) {
        let taskStatus = self.activeSections[indexPath.section]
        switch taskStatus {
        case .upcoming:
            view.sectionHeader.setContent(subheader: Strings("taskStatus.upcoming").local.uppercased())
            view.sectionHeader.sectionHeader.setTextColor(to: TickColors.upcomingTask)
        case .ongoing:
            view.sectionHeader.setContent(subheader: Strings("taskStatus.ongoing").local.uppercased())
            view.sectionHeader.sectionHeader.setTextColor(to: TickColors.ongoingTask)
        case .completed:
            view.sectionHeader.setContent(subheader: Strings("taskStatus.completed").local.uppercased())
            view.sectionHeader.sectionHeader.setTextColor(to: TickColors.completedTask)
        }
    }
    
    /// Configure how the task cards are drawn
    /// - Parameters:
    ///   - view: The view to configure
    ///   - indexPath: The index path of the view within the collection view
    private func configureTaskCard(cell: TaskCardViewCell, task: Task) {
        cell.card.setContent(title: task.title, description: task.description, duration: task.formattedOngoingDuration)
        self.configureTaskCardContextMenu(cell: cell, task: task)
        switch task.status {
        case .upcoming:
            cell.card.checkBox.setHidden(to: true)
        case .ongoing:
            cell.card.checkBox
                .setAccessibilityIdentifier(to: "ONGOING_CHECKBOX")
                .setHidden(to: false)
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setState(checked: false)
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    Session.inst.editTaskCompletion(task)
                    // We don't reload any data, so we must explicitly set the context menu
                    self.configureTaskCardContextMenu(cell: cell, task: task)
                })
        case .completed:
            cell.card.checkBox
                .setAccessibilityIdentifier(to: "COMPLETED_CHECKBOX")
                .setHidden(to: false)
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setState(checked: true)
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    Session.inst.editTaskCompletion(task)
                    // We don't reload any data, so we must explicitly set the context menu
                    self.configureTaskCardContextMenu(cell: cell, task: task)
                })
        }
    }
    
    /// Assign a context menu to a task card (depending on its status)
    /// - Parameters:
    ///   - cell: The view to configure
    ///   - task: The task it (the task card / view) represents
    private func configureTaskCardContextMenu(cell: TaskCardViewCell, task: Task) {
        // Create the actions
        let editAction = UIAction(title: Strings("label.edit").local, image: UIImage(systemName: "pencil"), attributes: []) { action in
            let newController = TaskFormViewController()
            newController.setToEdit(task: task)
            self.present(newController, animated: true)
        }
        let deleteAction = UIAction(title: Strings("label.delete").local, image: UIImage(systemName: "trash"), attributes: [.destructive]) { action in
            Session.inst.deleteTask(task)
        }
        // Assign menus with actions corresponding to the task status
        switch task.status {
        case .upcoming:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [editAction, deleteAction]))
        case .ongoing:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [deleteAction]))
        case .completed:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [deleteAction]))
        }
        // Here we detect when a context menu activates and ends
        // This way we can animate out any section headers
        // Section headers (particularly the top pinned one) clip into the shadow created by activating a context menu
        // We just quietly fade them out to avoid this
        cell.card
            .setOnContextMenuActivation({
                let sectionHeaders = self.collectionView.visibleSupplementaryViews(ofKind: TaskListSectionHeaderReusableView.ELEMENT_KIND) as! [TaskListSectionHeaderReusableView]
                sectionHeaders.forEach({
                    $0.sectionHeader.animateOpacity(to: 0.0, duration: 0.5)
                })
            })
            .setOnContextMenuEnd({
                let sectionHeaders = self.collectionView.visibleSupplementaryViews(ofKind: TaskListSectionHeaderReusableView.ELEMENT_KIND) as! [TaskListSectionHeaderReusableView]
                sectionHeaders.forEach({
                    $0.sectionHeader.setOpacity(to: 1.0)
                })
            })
    }
    
    /// Render the background of the section headers that are pinned to the top
    /// The motivation for this is as follows:
    /// We want the top header to have a background - when it's pinned, we don't want it to overlay the top card making both unreadable and ugly
    /// We don't want headers below the top/pinned one to have a background - when task cards animate between sections, it's cleaner to animate the section headers over them with no background
    /// - Parameters:
    ///   - lenience: How close a view has to be relative to the "pinned" section below the safe area (or how "off" it's allowed to be)
    private func renderSectionTopHeaderBackgrounds(lenience: Double) {
        let headers = collectionView.visibleSupplementaryViews(ofKind: TaskListSectionHeaderReusableView.ELEMENT_KIND) as! [TaskListSectionHeaderReusableView]
        var distancesFromTop = [Double]()
        let inset = Environment.inst.topSafeAreaHeight
        for headerView in headers {
            // This is the frame relative to the screen
            // IMPORTANT:
            // This isn't always particularly accurate with the scroll view moving
            // If the scroll view is moving quickly or jittering this can be off the rendered (actual) position
            // We pass a lenience parameter for this reason
            // It takes into account the margin of error
            // For instance, if the scroll view is moving a lot, tasks can't (and aren't) being edited and reloaded - all that matters is the closest-to top section header gets a background so when it's pinned it appears correct with a background
            // You lower the lenience when editing tasks because the scroll view isn't really moving much - the distance is a lot more accurate
            let distance = collectionView.convert(headerView.frame, to: nil).minY
            distancesFromTop.append(distance - inset)
        }
        for headerIndex in headers.indices {
            let header = headers[headerIndex]
            let distance = distancesFromTop[headerIndex]
            let isAtTop = isLessZero(distance - lenience)
            if isAtTop {
                header.sectionHeader.setBackgroundColor(to: TickColors.backgroundFill)
            } else {
                header.sectionHeader.setBackgroundColor(to: .clear)
            }
        }
    }
    
    // MARK: - Task Data
    
    /// The initial loading of the task data from persistent memory
    private func loadTaskData() {
        self.taskCollection = TaskCollection(tasks: Session.inst.readAllTasks())
        let sectionsToRender = self.activeSections
        let toRender = self.taskCollection.getSectionedTasks(onlyInclude: sectionsToRender)
        var snapshot = NSDiffableDataSourceSnapshot<TaskStatus, Task.ID>()
        snapshot.appendSections(sectionsToRender)
        for taskStatus in sectionsToRender {
            snapshot.appendItems(
                toRender.first(where: { $0.status == taskStatus })?.tasks.map({ $0.id }) ?? [],
                toSection: taskStatus
            )
        }
        self.taskListDataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    /// Refresh the task lists - this redraws/animates existent task cards to their new position, and also draw/animates in newly added task's cards
    /// - Parameters:
    ///   - animate: True to animate the changes to the list of task cards
    private func refreshTaskList(animate: Bool = true) {
        let sectionsToRender = self.activeSections
        let toRender = self.taskCollection.getSectionedTasks(onlyInclude: sectionsToRender)
        var snapshot = NSDiffableDataSourceSnapshot<TaskStatus, Task.ID>()
        snapshot.appendSections(sectionsToRender)
        for taskStatus in sectionsToRender {
            snapshot.appendItems(
                toRender.first(where: { $0.status == taskStatus })?.tasks.map({ $0.id }) ?? [],
                toSection: taskStatus
            )
        }
        self.taskListDataSource.apply(snapshot, animatingDifferences: animate)
        // Some section headers may be visible when they weren't before (or moved) - redraw their backgrounds
        self.renderSectionTopHeaderBackgrounds(lenience: 10)
    }
    
    /// A callback (conforms to DatabaseListener) on whenever a database operation is completed that changes the data
    /// - Parameters:
    ///   - operation: The operation of what was completed (causing the callback)
    ///   - tasks: All tasks post-change
    ///   - flags: Any flags passed by the operation to inform how this responder behaves
    func onTaskOperation(operation: DatabaseOperation, tasks: [Task], flags: [DatabaseTaskOperationFlag]) {
        self.taskCollection = TaskCollection(tasks: tasks)
        if flags.contains(.taskContentEdit) {
            // Existent tasks' content was edited - we have to reload the data (redraw the cells)
            self.collectionView.reloadData()
        }
        self.refreshTaskList()
    }
    
    // MARK: - Scrolling
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // End of scroll - this means tasks can be edited
        // Since they can be edited, when we animate, we want the section headers to appear to have no background
        // However we still want the pinned one to have a background
        self.renderSectionTopHeaderBackgrounds(lenience: 10)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // End of scroll - this means tasks can be edited
        // Since they can be edited, when we animate, we want the section headers to appear to have no background
        // However we still want the pinned one to have a background
        self.renderSectionTopHeaderBackgrounds(lenience: 10)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // A greater lenience is needed for high-speed or jittery scroll movements
        self.renderSectionTopHeaderBackgrounds(lenience: 80)
    }
    
}
