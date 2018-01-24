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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        aelog()
        generateLogLines(count: 200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        aelog()
        generateLogLines(count: 300)
    }
    
    // MARK: - Actions

    @IBAction func didTapLogButton(_ sender: UIButton) {
        let queue = DispatchQueue.global()
        queue.async {
            self.generateLogLines(count: Int.random(max: 1000))
            DispatchQueue.main.async(execute: {
                aelog(sender)
            })
        }
    }
    
    @IBAction func didTapToggleButton(_ sender: UIButton) {
        Console.shared.toggle()
    }
    
    // MARK: - Helpers
    
    func generateLogLines(count: Int) {
        for i in 0...count {
            aelog("I'm just a log line #\(i).")
        }
    }
    
}

extension Int {
    static func random(_ min: Int = 0, max: Int = Int.max) -> Int {
        return Int(arc4random_uniform(UInt32((max - min) + 1))) + min
    }
}
