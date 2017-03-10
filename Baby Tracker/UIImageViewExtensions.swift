//
//  UIImageViewExtensions.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/2/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

extension UIImageView {
    func imageFrame() -> CGRect? {
        guard let imageSize = image?.size else { return nil }
        
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = frame.size.width / frame.size.height
        
        var imageFrame:CGRect?
        let shouldGetScaledImageWidth = imageAspectRatio < viewAspectRatio
        if shouldGetScaledImageWidth {
            let scaleFactor = frame.size.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (frame.size.width - width) * 0.5
            imageFrame = CGRect(x: topLeftX, y: 0, width: width, height: frame.size.height)
        } else {
            let scaleFactor = frame.size.width / imageSize.width
            let height = imageSize.height * scaleFactor
            let topLeftY = (frame.size.height - height) * 0.5
            imageFrame = CGRect(x: 0, y: topLeftY, width: frame.size.width, height: height)
        }
        return imageFrame
    }
}
