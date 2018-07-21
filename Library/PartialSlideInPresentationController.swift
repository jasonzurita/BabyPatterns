import UIKit

public final class PartialSlideInPresentationController: UIPresentationController {
    private let _heightFraction: CGFloat
    private lazy var _dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        view.alpha = 0.0

        let tgr = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        view.addGestureRecognizer(tgr)
        return view
    }()

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let cv = containerView else {
            fatalError("No container view to present on")
        }

        let frameSize = size(forChildContentContainer: presentedViewController,
                             withParentContainerSize: cv.bounds.size)
        let yOrigin = cv.frame.height * (1 - _heightFraction)

        return CGRect(origin: CGPoint(x: 0, y: yOrigin), size: frameSize)
    }

    public init(presentedViewController: UIViewController,
                presenting presentingViewController: UIViewController?,
                heightFraction: CGFloat) {
        _heightFraction = heightFraction

        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
    }

    @objc func dismissController() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    public override func presentationTransitionWillBegin() {
        containerView?.insertSubview(_dimmingView, at: 0)

        _dimmingView.bindFrameToSuperviewBounds()
        guard let coordinator = presentedViewController.transitionCoordinator else {
            _dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self._dimmingView.alpha = 1.0
        })
    }

    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            _dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self._dimmingView.alpha = 0.0
        })
    }

    public override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    public override func size(forChildContentContainer _: UIContentContainer,
                              withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height * _heightFraction)
    }
}
