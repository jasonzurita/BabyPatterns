@testable import Library
@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

UIFont.registerFonts

final class Button: UIButton {
    var onTap: (() -> Void)?
    init() {
        super.init(frame: .zero)
        super.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        setTitleColor(.blue, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    @objc func buttonTapped() { onTap?() }
}

let vc = UIViewController()
let button = Button()
button.setTitle("Show Fyi Dialog", for: .normal)
vc.view.addSubview(button)
button.bindFrameToSuperviewBounds()

button.onTap = {
    let dialogSize: CGFloat = 150
    let frame = CGRect(x: vc.view.frame.width * 0.5 - (dialogSize * 0.5),
                       y: vc.view.frame.height * 0.5 - (dialogSize * 0.5),
                       width: dialogSize,
                       height: dialogSize)
    let fyi = FyiDialog(frame: frame, text: "Saved!")
    styleLabelFyiDialog(fyi)
    fyi.present(in: vc.view)
}

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
