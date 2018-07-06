import UIKit

protocol SlidableTextFieldContainer: UITextFieldDelegate {
    var containerView: UIView! { get }
    var containerCenterYConstraint: NSLayoutConstraint! { get }
    func slideContainerUp()
    func resetContainerHeight()
}

extension SlidableTextFieldContainer where Self: UIViewController {

    func slideContainerUp() {
        let delta = (view.frame.height - containerView.frame.height - view.safeAreaInsets.top) * 0.5
        let yOffset: CGFloat = 10

        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = -delta + yOffset
            self.view.layoutIfNeeded()
        }
    }

    func resetContainerHeight() {
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}
