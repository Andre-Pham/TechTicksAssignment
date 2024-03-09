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
    
    private var root: TickView { return TickView(self.view) }
    private let safeAreaOverlay = TickView()
    
    private var taskCollection = TaskCollection()
    private var activeSections: [TaskStatus] = [.ongoing, .upcoming, .completed]
    private var taskListDataSource: UICollectionViewDiffableDataSource<TaskStatus, Task.ID>!
    
    var listenerType = DatabaseListenerType.task
    weak var databaseController: LocalDatabase?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.databaseController = appDelegate?.databaseController
        
        self.setupViews()
        self.configureCollectionView()
        self.configureDataSource()
        self.loadTaskData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.databaseController?.removeListener(listener: self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
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
                let mainHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
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
        view.header.newTaskButton.setOnTap({
            let newController = NewTaskViewController()
            self.present(newController, animated: true)
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
        cell.card.setContent(title: task.title, description: task.description, duration: task.ongoingDuration.description, status: "TODO")
        self.configureTaskCardContextMenu(cell: cell, task: task)
        switch task.status {
        case .upcoming:
            cell.card.checkBox.removeFromSuperView()
            cell.card.setContextMenu(to: nil)
        case .ongoing:
            cell.card.checkBox
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    self.databaseController?.editTask(task)
                    self.configureTaskCardContextMenu(cell: cell, task: task)
                })
        case .completed:
            cell.card.checkBox
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setState(checked: true)
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    self.databaseController?.editTask(task)
                    self.configureTaskCardContextMenu(cell: cell, task: task)
                })
            cell.card.setContextMenu(to: nil)
        }
    }
    
    private func configureTaskCardContextMenu(cell: TaskCardViewCell, task: Task) {
        switch task.status {
        case .upcoming:
            cell.card.setContextMenu(to: nil)
        case .ongoing:
            let editAction = UIAction(title: Strings("label.edit").local, image: UIImage(systemName: "pencil"), attributes: []) { action in
                print("Edit")
            }
            let deleteAction = UIAction(title: Strings("label.delete").local, image: UIImage(systemName: "trash"), attributes: [.destructive]) { action in
                self.databaseController?.deleteTask(task)
            }
            cell.card
                .setContextMenu(to: UIMenu(title: Strings("label.taskOptions").local, children: [editAction, deleteAction]))
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
        case .completed:
            cell.card.setContextMenu(to: nil)
        }
    }
    
    private func loadTaskData() {
        self.taskCollection = TaskCollection(tasks: self.databaseController!.readAllTasks())
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
    
    func onTaskOperation(operation: DatabaseOperation, tasks: [Task]) {
        self.taskCollection = TaskCollection(tasks: tasks)
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
        self.taskListDataSource.apply(snapshot, animatingDifferences: true)
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
    public let header = TaskListHeaderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.header.view)
        self.header.constrainAllSides()
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
