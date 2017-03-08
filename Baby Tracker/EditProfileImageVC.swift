//
//  EditProfileImageVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 2/26/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import ImageIO

protocol EditProfileImageDelegate: class {
    func profileImageEdited(image:UIImage)
}

class EditProfileImageVC: UIViewController {

    weak var delegate:EditProfileImageDelegate?
    var imageCandidate:UIImage!
    fileprivate var cutoutCenter = CGPoint(x: UIScreen.main.bounds.size.width * 0.5, y: UIScreen.main.bounds.size.height * 0.5)

    
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
        guard let croppedCGImage = resizeOption2(image: image) else { return nil }
        
        return croppedCGImage
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

//image resizing
extension EditProfileImageVC {
    var cropRect1:CGRect{
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
    
    private var cropRect2:CGRect {
        guard let image = profileImageView.image, let imageFrame = profileImageView.imageFrame() else { return CGRect.zero }
        
        let imageToViewScale = image.size.width/view.frame.width
        let zoomScale = 1/scrollView.zoomScale
        let radius = cutoutCenter.x * 0.9
        let frame = CGRect(x: cutoutCenter.x - radius, y: cutoutCenter.y - radius, width: radius * 2, height: radius * 2)
        
        let x = (scrollView.contentOffset.x + frame.origin.x - imageFrame.origin.x) * zoomScale * imageToViewScale
        let y = (scrollView.contentOffset.y + frame.origin.y - imageFrame.origin.y) * zoomScale * imageToViewScale
        let width = frame.size.width * zoomScale * imageToViewScale
        let height = frame.size.height * zoomScale * imageToViewScale
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    fileprivate func resizeOption1(image:UIImage) -> UIImage? {
        // Define thumbnail size
        let size = cropRect2.size
        
        // Define rect for thumbnail
        let scale = max(size.width/image.size.width, size.height/image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let x = (size.width - width) / CGFloat(2)
        let y = (size.height - height) / CGFloat(2)
        let thumbnailRect = CGRect(x: x, y: y, width: width, height: height)
        
        // Generate thumbnail from image
        UIGraphicsBeginImageContextWithOptions(cropRect2.size, false, 0)
        image.draw(in: cropRect2)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
    
    fileprivate func resizeOption2(image:UIImage) -> UIImage? {
        let data = UIImageJPEGRepresentation(image, 0)

        if let imageSource = CGImageSourceCreateWithData(data as! CFData, nil) {
            let options: [NSString: NSObject] = [
                kCGImageSourceThumbnailMaxPixelSize: (max(cropRect1.size.width, cropRect1.size.height) * 0.25) as NSObject,
                kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject,
                kCGImageSourceCreateThumbnailWithTransform: true as NSObject
            ]
            
            return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?).flatMap { UIImage(cgImage: $0) }
        }
        return nil
    }
    
}

