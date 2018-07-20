import Framework_BabyPatterns
@testable import Library
import PlaygroundSupport
import UIKit

UIFont.registerFonts

let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
let superView = UIView(frame: frame)
superView.backgroundColor = .white

let button = UIButton()
superView.addSubview(button)

button.setTitle("History", for: .normal)

button.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
    button.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
    button.centerYAnchor.constraint(equalTo: superView.centerYAnchor),
    button.widthAnchor.constraint(equalTo: button.heightAnchor),
    button.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: 0.35),
    ])

superView.updateConstraintsIfNeeded()
styleButtonCircle(button)


PlaygroundPage.current.liveView = superView
