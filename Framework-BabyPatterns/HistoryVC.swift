//
//  HistoryVC.swift
//  AppFramework
//
//  Created by Jason Zurita on 11/14/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

public final class HistoryVC: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()
        print("hello world.")
    }

    public init() {
        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: HistoryVC.self))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
