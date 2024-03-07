//
//  ViewController.swift
//  Tick
//
//  Created by Andre Pham on 8/3/2024.
//

import UIKit

class ViewController: UIViewController {
    
    private let text = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.text)
        NSLayoutConstraint.activate([
            text.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            text.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        self.text.text = "Hello World"
        self.text.font = TickFont(font: TickFonts.Inter.Black, size: 50)
        self.text.textColor = TickColors.accent
    }

}
