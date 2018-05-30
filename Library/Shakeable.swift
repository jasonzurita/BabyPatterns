import UIKit

public protocol Shakeable {
    func shake()
}

public extension Shakeable where Self: UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 6
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 20.0, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 20.0, y: center.y))
        layer.add(animation, forKey: "position")
    }
}
