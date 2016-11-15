//
//  HomeVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    //outlets
    @IBOutlet weak var feedingTile: Tile!
    @IBOutlet weak var changingsTile: Tile!
    
    @IBOutlet weak var babyNameLabel: UILabel!
    @IBOutlet weak var babyAgeLabel: UILabel!
    @IBOutlet weak var todaysDateLabel: UILabel!
    @IBOutlet weak var babysProfilePictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        babyNameLabel.text = "James"
        babyAgeLabel.text = "7 Months old"
        todaysDateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
//        babysProfilePictureView.image = 
        
        for type in TileType.allValues {
            addTileWithTitle(type: type)
        }
    }
    
    private func addTileWithTitle(type:TileType) {
        switch type {
        case .feeding:
            feedingTile.titleLabel.text = "Feedings"
            feedingTile.detailLabel.text = "Last: 2 hrs"
        case .changings:
            changingsTile.titleLabel.text = "Changings"
            changingsTile.detailLabel.text = "Last: 4 hrs"

        }
    }
}

