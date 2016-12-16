//
//  ProfileView.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/15/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class ProfileView: UIView {
    
    //outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!

    override init(frame:CGRect) {
        super.init(frame:frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    private func initializeView() {
        loadNib()
        view.frame = bounds
        addSubview(view)
    }
    
    @IBAction func changeProfileImageButtonTapped(_ sender: UIButton) {
        
    }
    
}
