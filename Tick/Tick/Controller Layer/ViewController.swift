//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var root: TickView { return TickView(self.view) }
    private let header = TaskListHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        self.root
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(self.header)
        
        self.header
            .constrainCenterVertical()
            .constrainHorizontal()
            .setContent(header: "Hello World")
    }

}
