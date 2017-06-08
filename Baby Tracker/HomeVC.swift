//
//  HomeVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import ImageIO
import Firebase

class HomeVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        //TODO: auto rotate to add and view other children
        return .portrait
    }

    var feedingsVM: FeedingsVM?
    var profileVM: ProfileVM?
    var profilePhotoCandidate: UIImage?

    @IBOutlet weak var homeScreenTitle: UINavigationItem!
    @IBOutlet weak var profileView: ProfileView!

    //TODO: okay for for now, put these into a collectoin view to easily support future tile additions
    @IBOutlet weak var feedingTile: Tile!
    @IBOutlet weak var requestFeatureTile: Tile!

    @IBOutlet weak var adBannerView: GADBannerView!
    @IBOutlet weak var turnOffAdsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.delegate = self

        setupTileListeners()

        adBannerView.rootViewController = self
        adBannerView.delegate =  self
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "4796a5487323e9b9f16cf3dd3c0ada73" ]
        adBannerView.load(adRequest)
    }

    private func setupTileListeners() {
        feedingTile.didTapCallback = { [unowned self] in
            self.performSegue(withIdentifier: K.Segues.Feeding, sender: nil)
        }

        requestFeatureTile.didTapCallback = { [unowned self] in
            self.performSegue(withIdentifier: K.Segues.RequestFeature, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func updateUI() {
        updateProfileUI()
        updateFeedingUI()
    }

    internal func updateProfileUI() {
        guard let p = profileVM?.profile else { return }
        profileView.nameLabel.text = p.babyName
        homeScreenTitle.title = "Welcome \(p.parentName)!"
        profileView.imageView.image = p.profilePicture
    }

    private func updateFeedingUI() {
        guard let f = feedingsVM else { return }

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

        if let vc = segue.destination as? FeedingVC, let f = feedingsVM {
            vc.feedingsVM = f
            vc.profileVM = profileVM
        } else if let vc = segue.destination as? SettingsVC, let p = profileVM {
            vc.profileVM = p
        } else if let vc = segue.destination as? EditProfileImageVC, let i = profilePhotoCandidate {
            vc.imageCandidate = i
            vc.delegate = self
        }
    }
    @IBAction func turnOffAdsButtonPressed(_ sender: UIButton) {
        print("TODO: implement getting rid of ads")

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

extension HomeVC:EditProfileImageDelegate {
    func profileImageEdited(image: UIImage) {
        profileVM?.updateProfilePhoto(image:image)
        updateProfileUI()
    }
}

extension HomeVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }

        profilePhotoCandidate = resize(image: image)
        performSegue(withIdentifier: K.Segues.EditProfileImage, sender: nil)
    }

    fileprivate func resize(image: UIImage) -> UIImage? {
        guard let data = UIImageJPEGRepresentation(image, 0) else { return nil }
        guard let imageSource = CGImageSourceCreateWithData(data as NSData as CFData, nil) else { return nil }

        let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: (max(image.size.width, image.size.height) * 0.5) as NSObject,
            kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject,
            kCGImageSourceCreateThumbnailWithTransform: true as NSObject
        ]
        let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?)
        return thumbnail.flatMap { UIImage(cgImage: $0) }
    }

    private func rotatedImage(image: UIImage, orientation: UIImageOrientation) -> UIImage {

        UIGraphicsBeginImageContext(image.size)

        let context = UIGraphicsGetCurrentContext()

        if orientation == .right {
            context!.rotate(by: CGFloat(90)/CGFloat(180) * CGFloat.pi)
        } else if orientation == .left {
            context!.rotate(by: -CGFloat(90)/CGFloat(180) * CGFloat.pi)

        } else if orientation == .down {
            // NOTHING
        } else if orientation == .up {
            context!.rotate(by: CGFloat(90)/CGFloat(180) * CGFloat.pi)
        }

        image.draw(at: CGPoint(x: 0, y: 0))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension HomeVC: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        turnOffAdsButton.isHidden = false
    }
}
