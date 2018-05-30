import UIKit

public final class BarGraphLollipop: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet var circle: Circle!
    @IBOutlet var barView: UIView!

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupBarGraph()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBarGraph()
    }

    private func setupBarGraph() {
        loadNib()
        view.frame = bounds
        addSubview(view)
    }
}
