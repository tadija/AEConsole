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
            log("test log \(i)")
        }
    }

    @IBAction func buttonTopTapped(sender: AnyObject) {
        log("top button is tapped")
    }
    
    @IBAction func buttonCenterTapped(sender: AnyObject) {
        log("center button is tapped")
    }
    
    @IBAction func buttonBottomTapped(sender: AnyObject) {
        log("bottom button is tapped")
    }

}

