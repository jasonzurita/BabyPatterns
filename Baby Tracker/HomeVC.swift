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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let lastSide = feedings.lastFeedingSide()
        var sideText = lastSide.asText()
        if lastSide != .none {
            sideText += ": "
        }
        
        let hours = feedings.timeSinceLastFeeding().stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)
        
        feedingTile.detailLabel1.text = "\(sideText)" + hours.string + "h " + minutes.string + "m ago"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FeedingVC {
            vc.feedings = feedings
        }
    }
}

