//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var root: TickView { return TickView(self.view) }
    private let subheader = TaskListSubheaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        self.root
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(self.subheader)
        
        self.subheader
            .constrainCenterVertical()
            .constrainHorizontal()
            .setContent(subheader: "Hello World")
    }

}
