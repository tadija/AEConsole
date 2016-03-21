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

        for i in 0...100 {
            aelog("test log \(i)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        aelog()
    }

    @IBAction func buttonTopTapped(sender: AnyObject) {
        aelog(sender)
        aelog("top button is tapped")
    }
    
    @IBAction func buttonCenterTapped(sender: AnyObject) {
        aelog("center button is tapped - it has even longer longer much longer very longer text")
    }
    
    @IBAction func buttonBottomTapped(sender: AnyObject) {
        aelog("bottom button is tapped - it has longer log text")
    }

}

