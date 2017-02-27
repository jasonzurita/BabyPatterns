//
//  EditProfileImageVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 2/26/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class EditProfileImageVC: UIViewController {

    var imageCandidate:UIImage!
    
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
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: width * 0.5, y: height * 0.5), radius: width * 0.5 * 0.9, startAngle: 0.0, endAngle: 2 * CGFloat(M_PI), clockwise: false)
        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
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
