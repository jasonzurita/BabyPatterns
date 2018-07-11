import ImageIO
import Library
import UIKit

public protocol EditProfileImageDelegate: class {
    func profileImageEdited(image: UIImage)
}

public final class EditProfileImageVc: UIViewController, Loggable {
    public let shouldPrintDebugLog = true

    public weak var delegate: EditProfileImageDelegate?
    private let _imageCandidate: UIImage
    private var _cropRadius: CGFloat {
        return _cropCenter.x * 0.9
    }

    private var _cropCenter = CGPoint(x: UIScreen.main.bounds.size.width * 0.5,
                                     y: UIScreen.main.bounds.size.height * 0.5)

    @IBOutlet public var profileImageView: UIImageView! {
        didSet {
            profileImageView.image = _imageCandidate
        }
    }
    @IBOutlet public var overlayView: UIView!
    @IBOutlet public var scrollView: UIScrollView! {
        didSet {
            scrollView.maximumZoomScale = 4.0
        }
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public init(imageCandidate: UIImage) {
        _imageCandidate = imageCandidate
        super.init(nibName: nil, bundle: Bundle.framework)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureOverlay()
    }

    private func configureOverlay() {
        let path = CGMutablePath()
        path.addArc(center: _cropCenter,
                    radius: _cropRadius,
                    startAngle: 0.0,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: false)

        path.addRect(CGRect(x: 0, y: 0, width: overlayView.frame.width, height: overlayView.frame.height))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd

        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true
    }

    @IBAction func saveProfilePhoto(_: UIButton) {
        if let image = profileImageView.image, let editedImage = cropImage(image) {
            delegate?.profileImageEdited(image: editedImage)
        }
        dismissViewController(UIButton())
    }

    private func cropImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage, let cropRect = cropRect() else { return nil }
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage)
    }

    private func cropRect() -> CGRect? {
        guard let imageFrame = profileImageView.imageFrame() else { return nil }

        let frame = CGRect(x: _cropCenter.x - _cropRadius,
                           y: _cropCenter.y - _cropRadius,
                           width: _cropRadius * 2,
                           height: _cropRadius * 2)

        let imageSizeToFrameRatio = profileImageView.image!.size.width / imageFrame.width

        let y = (scrollView.contentOffset.y + frame.origin.y - imageFrame.origin.y) * imageSizeToFrameRatio
        let x = (scrollView.contentOffset.x + frame.origin.x - imageFrame.origin.x) * imageSizeToFrameRatio

        let width = frame.width * imageSizeToFrameRatio
        let height = frame.height * imageSizeToFrameRatio

        log("x: \(x), y:\(y), imageSizeToFrameRatio: \(imageSizeToFrameRatio)", object: self, type: .info)
        return CGRect(x: x, y: y, width: width, height: height)
    }

    @IBAction func dismissViewController(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditProfileImageVc: UIScrollViewDelegate {
    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return profileImageView
    }
}
