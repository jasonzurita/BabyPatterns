@testable import Library
@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
let superView = UIView(frame: frame)
superView.backgroundColor = .white

let stopButton = StopButton(onTap: {print("tapped")},
                            enabledColor: .bpDarkGray,
                            disabledColor: .bpLightGray)

superView.addSubview(stopButton)
stopButton.bindFrameToSuperviewBounds()

PlaygroundPage.current.liveView = superView
