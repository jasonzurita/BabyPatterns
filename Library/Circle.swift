import UIKit

public final class Circle: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircle()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircle()
    }

    private func setupCircle() {
        //        layer.cornerRadius = frame.width * 0.5
        layer.backgroundColor = UIColor.blue.cgColor
    }
}
