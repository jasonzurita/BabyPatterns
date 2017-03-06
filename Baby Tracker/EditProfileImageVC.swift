//
//  EditProfileImageVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 2/26/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

protocol EditProfileImageDelegate: class {
    func profileImageEdited(image:UIImage)
}

class EditProfileImageVC: UIViewController {

    weak var delegate:EditProfileImageDelegate?
    var imageCandidate:UIImage!
    private var cutoutCenter = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)
//    private var cropRect:CGRect? {
//        guard let image = profileImageView.image, let imageFrame = profileImageView.imageFrame() else { return nil }
//        
//        let imageToViewScale = image.size.width/view.frame.width
//        let zoomScale = 1/scrollView.zoomScale
//        let radius = cutoutCenter.x * 0.9
//        let frame = CGRect(x: cutoutCenter.x - radius, y: cutoutCenter.y - radius, width: radius * 2, height: radius * 2)
//
//        let x = (scrollView.contentOffset.x + frame.origin.x - imageFrame.origin.x) * zoomScale * imageToViewScale
//        let y = (scrollView.contentOffset.y + frame.origin.y - imageFrame.origin.y) * zoomScale * imageToViewScale
//        let width = frame.size.width * zoomScale * imageToViewScale
//        let height = frame.size.height * zoomScale * imageToViewScale
//        return CGRect(x: x, y: y, width: width, height: height)
//    }
    
    var cropRect:CGRect{
        get{
            let factor = profileImageView.image!.size.width/view.frame.width
            let scale = 1/scrollView.zoomScale
            let imageFrame = profileImageView.imageFrame()!
                    let radius = cutoutCenter.x * 0.9

                    let frame = CGRect(x: cutoutCenter.x - radius, y: cutoutCenter.y - radius, width: radius * 2 * factor, height: radius * 2 * factor)
            let x = (scrollView.contentOffset.x) * scale
            let y = (scrollView.contentOffset.y) * scale
            let width = frame.size.width * scale
            let height = frame.size.height * scale
            return CGRect(x: x, y: y, width: width, height: height)
        }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.image = imageCandidate
        scrollView.maximumZoomScale = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureOverlay()
    }
    
    private func configureOverlay() {
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
        let radius = cutoutCenter.x * 0.9
        path.addArc(center: cutoutCenter, radius: radius, startAngle: 0.0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
    }
    
    @IBAction func saveProfilePhoto(_ sender: UIButton) {
        if let image = profileImageView.image, let editedImage = cropImage(image) {
            delegate?.profileImageEdited(image: editedImage)
//            profileImageView.image = editedImage
        }
        dismissViewController(UIButton())
    }
    
    private func cropImage(_ image:UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage)
    }
    
    @IBAction func dismissViewController(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileImageVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return profileImageView
    }
}
