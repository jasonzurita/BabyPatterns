//
//  HomeVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    override var shouldAutorotate: Bool {
        //TODO: auto rotate to add and view other children
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //properites
    var feedings:FeedingVM?
    
    //outlets
    //TODO: okay for for now, put these into a collectoin view to easily support future tile additions
    @IBOutlet weak var feedingTile: Tile!
    @IBOutlet weak var profileView: ProfileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.delegate = self
        
        setupTileListeners()
    }
    
//    private func loadFeedingData() {
//        feedings.loadData(completionHandler: { [weak self] in
//            guard let strongSelf = self else { return }
//            
//            DispatchQueue.main.async {
//                strongSelf.updateUI()
//            }
//        })
//    }
    
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
        guard let f = feedings else { return }
        
        let lastSide = f.lastFeedingSide()
        var sideText = lastSide.asText()
        if lastSide != .none {
            sideText += ": "
        }
        
        let hours = f.timeSinceLastFeeding().stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)
        
        feedingTile.detailLabel1.text = "\(sideText)" + hours.string + "h " + minutes.string + "m ago"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? FeedingVC, let f = feedings {
            vc.feedings = f
        }
    }
}

extension HomeVC: ProfileViewDelegate {
    func changeProfileImageButtonTapped() {
        
        let actionSheet = UIAlertController(title: "Change Profile Photo?", message: nil, preferredStyle: .actionSheet)
        
        let libraryOption = UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.getProfileImage(sourceType: .photoLibrary)
        })
        
        let cameraOption = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.getProfileImage(sourceType: .camera)
        })
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            actionSheet.dismiss(animated: true, completion: nil)
        })
        
        actionSheet.addAction(libraryOption)
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(cancelOption)
        
        present(actionSheet, animated: true, completion: nil)

    }
    
    private func getProfileImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
}

extension HomeVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        profileView.imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}
