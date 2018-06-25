import UIKit

public final class StopButton: UIButton {
    private let _onTap: () -> Void
    private let _centerSquare = UIView()
    private let _enabledColor: UIColor
    private let _disabledColor: UIColor
    public var isDisabled = false {
        didSet {
            updateColor()
        }
    }

    public init(onTap: @escaping () -> Void, enabledColor: UIColor, disabledColor: UIColor) {
        _onTap = onTap
        _enabledColor = enabledColor
        _disabledColor = disabledColor
        super.init(frame: .zero)
        configureView()
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func layoutSubviews() {
        layer.cornerRadius = frame.height * 0.5
    }

    private func configureView() {
        addTarget(self, action: #selector(onTap), for: .touchUpInside)

        layer.borderWidth = 1.0

        _centerSquare.isUserInteractionEnabled = false
        addSubview(_centerSquare)

        _centerSquare.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _centerSquare.centerXAnchor.constraint(equalTo: centerXAnchor),
            _centerSquare.centerYAnchor.constraint(equalTo: centerYAnchor),
            _centerSquare.heightAnchor.constraint(equalTo: _centerSquare.widthAnchor),
            _centerSquare.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
        ])
        updateColor()
    }

    private func updateColor() {
        let color = isDisabled ? _disabledColor : _enabledColor
        layer.borderColor = color.cgColor
        _centerSquare.backgroundColor = color
    }

    @objc func onTap() {
        guard !isDisabled else { return }
        _onTap()
    }
}
