//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var root: TickView { return TickView(self.view) }
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let taskCollection = TaskCollection()
    private var renderedTasks = [[Task]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            .addSubview(TickView(self.collectionView))
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        TickView(self.collectionView)
            .setBackgroundColor(to: TickColors.backgroundFill)
            .constrainAllSides(respectSafeArea: false)
        
        self.collectionView.register(
            TaskCardViewCell.self,
            forCellWithReuseIdentifier: TaskCardViewCell.REUSE_IDENTIFIER
        )
        self.collectionView.register(
            TaskListSubheaderReusableView.self,
            forSupplementaryViewOfKind: TaskListSubheaderReusableView.ELEMENT_KIND,
            withReuseIdentifier: TaskListSubheaderReusableView.REUSE_IDENTIFIER
        )
        self.collectionView.register(
            TaskListHeaderReusableView.self,
            forSupplementaryViewOfKind: TaskListHeaderReusableView.ELEMENT_KIND,
            withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER
        )
        
        self.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // Define size and items like before
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: TickDimensions.screenContentPaddingVertical,
                leading: TickDimensions.screenContentPaddingHorizontal,
                bottom: TickDimensions.screenContentPaddingVertical,
                trailing: TickDimensions.screenContentPaddingHorizontal
            )
            section.interGroupSpacing = 2
            let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: TaskListSubheaderReusableView.ELEMENT_KIND,
                alignment: .top
            )
            sectionHeader.pinToVisibleBounds = true
            if sectionIndex == 0 {
                let mainHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
                let mainHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: mainHeaderSize,
                    elementKind: TaskListHeaderReusableView.ELEMENT_KIND,
                    alignment: .top,
                    absoluteOffset: CGPoint(x: 0.0,
                    y: -40)
                )
                section.boundarySupplementaryItems = [mainHeader, sectionHeader]
            } else {
                section.boundarySupplementaryItems = [sectionHeader]
            }
            return section
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.renderedTasks.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.renderedTasks[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCardViewCell.REUSE_IDENTIFIER, for: indexPath) as! TaskCardViewCell
        let task = self.renderedTasks[indexPath.section][indexPath.row]
        cell.card.setContent(title: task.title, description: task.description, duration: task.ongoingDuration.description, status: "TODO")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == TaskListHeaderReusableView.ELEMENT_KIND {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TaskListHeaderReusableView.REUSE_IDENTIFIER,
                for: indexPath
            ) as! TaskListHeaderReusableView
            view.header.setContent(header: "TODO")
            return view
        } else if kind == TaskListSubheaderReusableView.ELEMENT_KIND {
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TaskListSubheaderReusableView.REUSE_IDENTIFIER,
                for: indexPath
            ) as! TaskListSubheaderReusableView
            view.subheader.setContent(subheader: "TODO SUBHEADER")
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

}

class TaskListSubheaderReusableView: UICollectionReusableView {

    public static let REUSE_IDENTIFIER = UUID().uuidString
    public static let ELEMENT_KIND = UUID().uuidString
    public let subheader = TaskListSubheaderView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.subheader.view)
        self.subheader.constrainAllSides()
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.red.cgColor
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
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.green.cgColor
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
        
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.blue.cgColor
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        width.constant = bounds.size.width
        return contentView.systemLayoutSizeFitting(CGSize(width: targetSize.width, height: 1))
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
