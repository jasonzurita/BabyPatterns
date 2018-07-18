import UIKit

protocol SlidableTextFieldContainer: UITextFieldDelegate {
    var containerView: UIView! { get }
    var containerCenterYConstraint: NSLayoutConstraint! { get }
    func slideContainerUp(_ bottomObstructingViewHeight: CGFloat)
    func resetContainerHeight()
}

extension SlidableTextFieldContainer where Self: UIViewController {

    func slideContainerUp(_ bottomObstructingViewHeight: CGFloat) {
        let visibleWindowHeight = (view.frame.height - view.safeAreaInsets.top - bottomObstructingViewHeight) * 0.5
        // note: using the view's height below is equal to the content view's normal y midpoint
        // this is okay for now, but should be looked at again to make it more robust.
        let delta = (view.frame.height - view.safeAreaInsets.top) * 0.5 - visibleWindowHeight

        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = -delta
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
