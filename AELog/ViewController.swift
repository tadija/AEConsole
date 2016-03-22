//
//  ViewController.swift
//  AELog
//
//  Created by Marko Tadic on 3/16/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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

    @IBAction func buttonTopTapped(sender: AnyObject) {
        aelog("top button is tapped")
        generateLogLines(count: 30)
    }
    
    @IBAction func buttonCenterTapped(sender: AnyObject) {
        aelog(sender)
        aelog("center button is tapped - it has even longer longer much longer very longer text")
    }
    
    @IBAction func buttonBottomTapped(sender: AnyObject) {
        aelog(sender)
        aelog("bottom button is tapped - it has longer log text")
        generateLogLines(count: 500)
    }
    
    private func generateLogLines(count count: Int) {
        for i in 0...count {
            aelog("test log line \(i)")
        }
    }

}

