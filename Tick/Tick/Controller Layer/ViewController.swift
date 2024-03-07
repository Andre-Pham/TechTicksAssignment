//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController {
    
    private var root: TickView { return TickView(self.view) }
    private let card = TaskCardView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        self.root
            .setBackgroundColor(to: TickColors.backgroundFill)
            .addSubview(self.card)
        
        self.card
            .constrainHorizontal(padding: 12)
            .constrainCenterVertical()
            .setContent(
                title: "Hello World",
                description: "This is a place holder component",
                duration: "Duration Text",
                status: "Status Text"
            )
    }

}
