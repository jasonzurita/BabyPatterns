import UIKit

enum TileType {
    case feeding
    case changings

    static let allValues = [feeding, changings]
}

class Tile: UIView {
    // constants
    private let shouldPrintDebugString = true // set to false to silence this class

    var didTapCallback: (() -> Void)?

    @IBInspectable var title: String? {
        didSet { titleLabel.text = title }
    }

    @IBInspectable var image: UIImage? {
        didSet { imageView.image = image }
    }

    @IBOutlet var view: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel1: UILabel!
    @IBOutlet var detailLabel2: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }

    private func initializeView() {
        loadNib()
        view.frame = bounds
        addSubview(view)

        detailLabel1.text = ""
        detailLabel2.text = ""
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        didTapCallback?()
    }
}
