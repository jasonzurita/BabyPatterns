import UIKit

precedencegroup SingleTypeComposition {
    associativity: right
}

infix operator<>: SingleTypeComposition
func<> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}

// MARK: Label Styles
let styleBaseLabel: (UILabel) -> Void = {
    $0.numberOfLines = 0
}

func styleLabelFont(_ font: UIFont) -> (UILabel) -> Void {
    return {
        $0.font = font
    }
}

func styleLabelColor(_ color: UIColor) -> (UILabel) -> Void {
    return {
        $0.textColor = color
    }
}

let styleH2Label =
    styleBaseLabel
        <> styleLabelFont(.notoSansBold(ofSize: 16))
        <> styleLabelColor(.bpMediumGray)
