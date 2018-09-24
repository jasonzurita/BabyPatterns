import UIKit

public final class TapableView: UIView {
    public var onTap: ((UIView) -> Void)?

    public init() {
        super.init(frame: .zero)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tgr)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    @objc func tapped() { onTap?(self) }
}
