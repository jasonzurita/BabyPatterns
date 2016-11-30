//
//  HomeVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    let feedings = Feedings()
    
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

        setupFeeding()
    }
    
    private func setupFeeding() {
        //TODO: convert this to hours and minutes
        let timeSinceLastFeeding = feedings.timeSinceLastFeeding().hours()
        feedingTile.detailLabel.text = "Last feeding:\n\(timeSinceLastFeeding) hours ago"
        
        feedingTile.didTapCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: Constants.Segues.FeedingSegue, sender: nil)
        }
    }
}

