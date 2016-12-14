//
//  HomeVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    //properites
    let feedings = FeedingFacade()
    
    
    //outlets
    //TODO: okay for for now, put these into a collectoin view to easily support future tile additions
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

        loadFeedingData()
        setupTileListeners()
    }
    
    private func loadFeedingData() {
        feedings.loadData(completionHandler: { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.updateUI()
            }
        })
    }
    
    private func setupTileListeners() {
        feedingTile.didTapCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.performSegue(withIdentifier: Constants.Segues.FeedingSegue, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    private func updateUI() {
        updateFeedingUI()
    }
    
    private func updateFeedingUI() {
        //TODO: convert this to hours and minutes && put this into a global utility class or extension
        
        func hoursAndMinutes(time:TimeInterval) -> (hours:Int, minutes:Int){
            let hours = floor(time / 3600)
            let timeWithoutHours = time - hours * 3600
            let minutes = floor(timeWithoutHours / 60)
            return (Int(hours),Int(minutes))
        }
        
        let lastFeed = hoursAndMinutes(time: feedings.timeSinceLastFeeding())
        
        let lastSide = feedings.lastFeedingSide()
        var sideText = lastSide.asText()
        if lastSide != .none {
            sideText += ": "
        }
        feedingTile.detailLabel1.text = "\(sideText)\(lastFeed.hours)h \(lastFeed.minutes)m ago"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FeedingVC {
            vc.feedings = feedings
        }
    }
}

