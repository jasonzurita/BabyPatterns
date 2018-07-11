import Firebase
import Framework_BabyPatterns
import ImageIO
import UIKit

class HomeVC: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // TODO: auto rotate to add and view other children
        return .portrait
    }

    private var adsManager = AdsDisplayManager()
    var feedingsVM: FeedingsVM?
    var profileVM: ProfileVM?
    var configuration: Configuration?
    var profilePhotoCandidate: UIImage?

    @IBOutlet var homeScreenTitle: UINavigationItem!
    @IBOutlet var profileView: ProfileView!

    // TODO: okay for for now, put these into a collectoin view to easily support future tile additions
    @IBOutlet var feedingTile: Tile!
    @IBOutlet var requestFeatureTile: Tile!

    @IBOutlet var adBannerView: GADBannerView!
    @IBOutlet var turnOffAdsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.delegate = self

        setupTileListeners()
    }

    private func setupTileListeners() {
        feedingTile.didTapCallback = { [unowned self] in
            self.performSegue(withIdentifier: K.Segues.Feeding, sender: nil)
        }

        requestFeatureTile.didTapCallback = { [unowned self] in
            let requestTVC = RequestFeatureTVC()
            self.navigationController?.pushViewController(requestTVC, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()

        let state: AdsDisplayState = configuration?.adsState ?? .initialInstall
        adsManager.update(adBannerView,
                          for: state,
                          additionalViewsToManage: [turnOffAdsButton])
    }

    private func updateUI() {
        updateProfileUI()
        updateFeedingUI()
    }

    internal func updateProfileUI() {
        guard let p = profileVM?.profile else { return }
        profileView.nameLabel.text = p.babyName
        homeScreenTitle.title = "Welcome \(p.parentName)!"

        let image = p.profilePicture ?? UIImage(named: "defaultProfileImage")
        profileView.imageView.image = image
    }

    private func updateFeedingUI() {
        guard let f = feedingsVM else { return }

        let lastSide = f.lastFeedingSide(for: .nursing)
        var sideText = lastSide.asText()
        if lastSide != .none {
            sideText += ": "
        }

        let hours = f.timeSinceLastFeeding().stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)

        feedingTile.detailLabel1.text = "\(sideText)" + hours.string + "h " + minutes.string + "m ago"
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let vc = segue.destination as? FeedingVC, let f = feedingsVM {
            vc.feedingsVM = f
            vc.profileVM = profileVM
        } else if let vc = segue.destination as? SettingsVC, let p = profileVM {
            vc.profileVM = p
            vc.configuration = configuration
        } else if let vc = segue.destination as? EditProfileImageVc /* ,let i = profilePhotoCandidate */ {
//            vc.imageCandidate = i
            vc.delegate = self
        }
    }

    @IBAction func turnOffAdsButtonPressed(_: UIButton) {
        let vc = TurnOffAdsVC()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
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

extension HomeVC: EditProfileImageDelegate {
    func profileImageEdited(image: UIImage) {
        profileVM?.updateProfilePhoto(image: image)
        updateProfileUI()
    }
}

extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
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
            kCGImageSourceCreateThumbnailWithTransform: true as NSObject,
        ]
        let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?)
        return thumbnail.flatMap { UIImage(cgImage: $0) }
    }

    private func rotatedImage(image: UIImage, orientation: UIImageOrientation) -> UIImage {
        UIGraphicsBeginImageContext(image.size)

        let context = UIGraphicsGetCurrentContext()

        // TODO: use a switch statement silly
        if orientation == .right {
            context!.rotate(by: CGFloat(90) / CGFloat(180) * CGFloat.pi)
        } else if orientation == .left {
            context!.rotate(by: -CGFloat(90) / CGFloat(180) * CGFloat.pi)

        } else if orientation == .down {
            // NOTHING
        } else if orientation == .up {
            context!.rotate(by: CGFloat(90) / CGFloat(180) * CGFloat.pi)
        }

        image.draw(at: CGPoint(x: 0, y: 0))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension HomeVC: GADBannerViewDelegate {
    func adViewDidReceiveAd(_: GADBannerView) {
        turnOffAdsButton.isHidden = false
    }
}
