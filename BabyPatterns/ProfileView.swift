import UIKit

public protocol ProfileViewDelegate: class {
    func changeProfileImageButtonTapped()
}

public final class ProfileView: UIView {
    public weak var delegate: ProfileViewDelegate?

    @IBOutlet public var view: UIView!
    @IBOutlet public var imageView: UIImageView!
    @IBOutlet public var nameLabel: UILabel!
    @IBOutlet public var ageLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }

    private func initializeView() {
        loadNib()
        view.frame = bounds
        addSubview(view)

        imageView.layer.masksToBounds = true
    }

    public override func draw(_: CGRect) {
        imageView.layer.cornerRadius = imageView.frame.height * 0.5
    }

    @IBAction func changeProfileImageButtonTapped(_: UIButton) {
        delegate?.changeProfileImageButtonTapped()
    }
}
