//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UICollectionViewController, DatabaseListener {
    
    private static let TASK_CARD_SPACING = 12.0
    private static let SECTION_PADDING_TOP = 0.0
    private static let SECTION_PADDING_BOTTOM = 14.0
    private static let SECTION_PADDING_LEFT = 14.0
    private static let SECTION_PADDING_RIGHT = 14.0
    private static let SECTION_HEADER_HEIGHT = 36.0
    private static let HEADER_HEIGHT = 130.0
    
    private var root: TickView { return TickView(self.view) }
    private let safeAreaOverlay = TickView()
    
    private let minuteMonitor = MinuteMonitor()
    private var taskCollection = TaskCollection()
    private var activeSections: [TaskStatus] = [.ongoing, .upcoming, .completed]
    private var taskListDataSource: UICollectionViewDiffableDataSource<TaskStatus, Task.ID>!
    
    var listenerType = DatabaseListenerType.task

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.configureCollectionView()
        self.configureDataSource()
        self.loadTaskData()
        
        self.minuteMonitor.startMonitoring {
            let tasksToRedraw = self.taskCollection.getTasks(triggeringAt: Date())
            if !tasksToRedraw.isEmpty {
                self.collectionView.reloadData()
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
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.safeAreaOverlay
                .removeHeightConstraint()
                .setHeightConstraint(to: Environment.inst.topSafeAreaHeight)
        }, completion: nil)
    }
    
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
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Self.SECTION_HEADER_HEIGHT))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: TaskListSectionHeaderReusableView.ELEMENT_KIND,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            if sectionIndex == 0 {
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
    
    private func configureDataSource() {
        let taskCellRegistration = UICollectionView.CellRegistration<TaskCardViewCell, Task> { cell, indexPath, task in
            self.configureTaskCard(cell: cell, task: task)
        }
        self.taskListDataSource = UICollectionViewDiffableDataSource(collectionView: self.collectionView) { [self] collectionView, indexPath, identifier -> UICollectionViewCell in
            let task = self.taskCollection.getTask(id: identifier)
            return self.collectionView.dequeueConfiguredReusableCell(using: taskCellRegistration, for: indexPath, item: task)
        }
        self.taskListDataSource.supplementaryViewProvider = { (view, kind, indexPath) in
            if kind == TaskListHeaderReusableView.ELEMENT_KIND {
                let view = self.collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER,
                    for: indexPath
                ) as! TaskListHeaderReusableView
                self.configureTaskListHeader(view: view, indexPath: indexPath)
                return view
            } else if kind == TaskListSectionHeaderReusableView.ELEMENT_KIND {
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
    
    private func configureTaskListHeader(view: TaskListHeaderReusableView, indexPath: IndexPath) {
        view.header.setContent(header: Strings("header.tasks").local)
        view.header.newTaskButton
            .setAccessibilityIdentifier(to: "NEW_TASK_BUTTON")
            .setOnTap({
                let newController = NewTaskViewController()
                self.present(newController, animated: true)
            })
        view.header.filterControls
            .setOnTap({ status in
                let oldSections = self.activeSections
                if let status {
                    self.activeSections = [status]
                } else {
                    self.activeSections = [.ongoing, .upcoming, .completed]
                }
                if oldSections != self.activeSections {
                    self.refreshTaskList(animate: false)
                }
            })
    }
    
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
                    self.configureTaskCardContextMenu(cell: cell, task: task)
                })
        }
    }
    
    private func configureTaskCardContextMenu(cell: TaskCardViewCell, task: Task) {
        let editAction = UIAction(title: Strings("label.edit").local, image: UIImage(systemName: "pencil"), attributes: []) { action in
            let newController = NewTaskViewController()
            newController.setToEdit(task: task)
            self.present(newController, animated: true)
        }
        let deleteAction = UIAction(title: Strings("label.delete").local, image: UIImage(systemName: "trash"), attributes: [.destructive]) { action in
            Session.inst.deleteTask(task)
        }
        switch task.status {
        case .upcoming:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [editAction, deleteAction]))
        case .ongoing:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [deleteAction]))
        case .completed:
            cell.card.setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [deleteAction]))
        }
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
        self.renderSectionTopHeaderBackgrounds(lenience: 10)
    }
    
    func onTaskOperation(operation: DatabaseOperation, tasks: [Task], flags: [DatabaseTaskOperationFlag]) {
        self.taskCollection = TaskCollection(tasks: tasks)
        if flags.contains(.taskContentEdit) {
            self.collectionView.reloadData()
        }
        self.refreshTaskList()
    }
    
    private func renderSectionTopHeaderBackgrounds(lenience: Double) {
        let headers = collectionView.visibleSupplementaryViews(ofKind: TaskListSectionHeaderReusableView.ELEMENT_KIND) as! [TaskListSectionHeaderReusableView]
        var distancesFromTop = [Double]()
        let inset = Environment.inst.topSafeAreaHeight
        for headerView in headers {
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
