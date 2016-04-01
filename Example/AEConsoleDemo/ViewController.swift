//
//  ViewController.swift
//  AEConsoleDemo
//
//  Created by Marko Tadic on 4/1/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit
import AEConsole

class ViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        aelog()
        generateLogLines(count: 100)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        aelog()
        generateLogLines(count: 200)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        aelog()
        generateLogLines(count: 300)
    }
    
    // MARK: - Actions

    @IBAction func didTapButton(sender: UIButton) {
        aelog(sender)
        generateLogLines(count: Int.random(max: 218))
    }
    
    @IBAction func didChangeSwitchValue(sender: UISwitch) {
        if sender.on {
            AEConsole.show()
        } else {
            AEConsole.hide()
        }
    }
    
    // MARK: - Helpers
    
    func generateLogLines(count count: Int) {
        for i in 0...count {
            aelog("I'm just a log line #\(i).")
        }
    }
    
}

extension Int {
    static func random(min: Int = 0, max: Int = Int.max) -> Int {
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}