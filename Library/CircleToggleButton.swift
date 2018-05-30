import UIKit

open class CircleToggleButton: UIButton {
    @IBInspectable var normalColor: UIColor = UIColor.gray {
        didSet {
            backgroundColor = normalColor
        }
    }

    @IBInspectable var activeColor: UIColor = UIColor.blue
    @IBInspectable var normalText: String = "Left" {
        didSet {
            setTitle(normalText, for: .normal)
        }
    }

    private var activeBorder: UIView?

    @IBInspectable public var isActive: Bool = false {
        didSet {
            updateButton()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        layer.cornerRadius = frame.width * 0.5
        backgroundColor = normalColor
        setTitle(normalText, for: .normal)
    }

    private func updateButton() {
        if isActive {
            backgroundColor = activeColor

            guard activeBorder == nil else { return }
            let border = makeActiveBorder()
            insertSubview(border, at: 0)
            activeBorder = border
        } else {
            backgroundColor = normalColor

            setTitle(normalText, for: .normal)

            activeBorder?.removeFromSuperview()
            activeBorder = nil
        }
    }

    private func makeActiveBorder() -> UIView {
        let delta: CGFloat = 8
        let largerFrame = CGRect(x: -(delta * 0.5),
                                 y: -(delta * 0.5),
                                 width: frame.width + delta,
                                 height: frame.height + delta)

        let view = UIView(frame: largerFrame)
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = activeColor.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = largerFrame.width * 0.5
        view.isUserInteractionEnabled = false

        return view
    }
}
