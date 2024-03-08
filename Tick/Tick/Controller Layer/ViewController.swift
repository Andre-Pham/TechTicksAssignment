//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, DatabaseListener {
    
    private static let TASK_CARD_SPACING = 12.0
    private static let SECTION_PADDING_TOP = 0.0
    private static let SECTION_PADDING_BOTTOM = 14.0
    private static let SECTION_PADDING_LEFT = 14.0
    private static let SECTION_PADDING_RIGHT = 14.0
    private static let SECTION_HEADER_HEIGHT = 36.0
    
    private var root: TickView { return TickView(self.view) }
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var taskCollection = TaskCollection()
    private var renderedTasks = [TaskCollection.TaskGrouping]()
    
    // Core Data
    var listenerType = DatabaseListenerType.task
    weak var databaseController: LocalDatabase?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.databaseController = appDelegate?.databaseController
        
        // Populate task collection with dummy tasks
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.taskCollection.addTask(Task(title: "Shopping", description: "Go shopping for cookies and brownies and lots of cake!", ongoingDuration: DateInterval(start: Date(), duration: 432_000), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Grocery Shopping", description: "Buy ingredients for the week's meals.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-20")!, duration: 86_400), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Gardening", description: "Prune the roses and prepare soil for spring planting.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-21")!, duration: 172_800), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Paint the Bedroom", description: "Paint the master bedroom with the chosen color scheme.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-22")!, duration: 259_200), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Car Service", description: "Take the car for its annual service and checkup.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-24")!, duration: 86_400), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Book Club Meeting", description: "Host the monthly book club meeting.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-27")!, duration: 86_400), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Spring Cleaning", description: "Deep clean the house for spring, focusing on the attic and garage.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-28")!, duration: 432_000), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Tax Preparation", description: "Gather all documents and complete tax returns.", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-30")!, duration: 86_400), markedComplete: false))
        self.taskCollection.addTask(Task(title: "Shopping", description: "Go shopping for cookies and brownies and lots of cake!", ongoingDuration: DateInterval(start: dateFormatter.date(from: "2024-03-31")!, duration: 432_000), markedComplete: true))
        self.renderedTasks = self.taskCollection.getSectionedTasks(onlyInclude: [.ongoing, .upcoming, .completed])
        
        self.root
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(TickView(self.collectionView))
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        TickView(self.collectionView)
            .setBackgroundColor(to: TickColors.backgroundFill)
            .constrainHorizontal()
            .constrainTop()
            .constrainBottom(respectSafeArea: false)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.databaseController?.removeListener(listener: self)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.renderedTasks.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.renderedTasks[section].grouping.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCardViewCell.REUSE_IDENTIFIER, for: indexPath) as! TaskCardViewCell
        let task = self.renderedTasks[indexPath.section].grouping[indexPath.row]
        cell.card.setContent(title: task.title, description: task.description, duration: task.ongoingDuration.description, status: "TODO")
        switch task.status {
        case .upcoming:
            cell.card.checkBox.removeFromSuperView()
        case .ongoing:
            cell.card.checkBox
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    self.databaseController?.editTask(task)
                })
        case .completed:
            cell.card.checkBox
                .setColor(checked: TickColors.completedTask, unchecked: TickColors.ongoingTask)
                .setIcon(to: "checkmark")
                .setState(checked: true)
                .setOnRelease({ isChecked in
                    task.setCompletedStatus(to: isChecked)
                    self.databaseController?.editTask(task)
                })
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == TaskListHeaderReusableView.ELEMENT_KIND {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER,
                for: indexPath
            ) as! TaskListHeaderReusableView
            view.header.setContent(header: Strings("header.tasks").local)
            view.header.newTaskButton.setOnTap({
                let newController = NewTaskViewController()
                self.present(newController, animated: true)
            })
            return view
        } else if kind == TaskListSectionHeaderReusableView.ELEMENT_KIND {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TaskListSectionHeaderReusableView.REUSE_IDENTIFIER,
                for: indexPath
            ) as! TaskListSectionHeaderReusableView
            let taskStatus = self.renderedTasks[indexPath.section].status
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
            return view
        }
        fatalError("Unrecognized element kind passed")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    func onTaskOperation(operation: DatabaseOperation, tasks: [Task]) {
        print("onTaskOperation - updates received")
        self.taskCollection = TaskCollection(tasks: tasks)
        self.renderedTasks = self.taskCollection.getSectionedTasks(onlyInclude: [.ongoing, .upcoming, .completed])
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
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
