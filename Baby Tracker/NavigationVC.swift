//
//  NavigationVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/26/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllers.last?.supportedInterfaceOrientations ?? .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
