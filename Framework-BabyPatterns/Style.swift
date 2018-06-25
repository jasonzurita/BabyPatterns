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
let styleLabelBase: (UILabel) -> Void = {
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

let styleLabelH2 =
    styleLabelBase
        <> styleLabelFont(.notoSansBold(ofSize: 16))
        <> styleLabelColor(.bpMediumGray)

let styleLabelBody =
    styleLabelBase
        <> styleLabelFont(.notoSansRegular(ofSize: 16))
        <> styleLabelColor(.bpMediumGray)

// MARK: Buttons
let styleButtonBase: (UIButton) -> Void = { _ in 
    // noop
}

let styleButtonCornerRadius: (UIButton) -> Void = {
    $0.layer.cornerRadius = $0.frame.height * 0.5
    $0.layer.masksToBounds = true
}

let styleButtonSave =
    styleButtonBase
        <> styleButtonCornerRadius
        <> {
            $0.backgroundColor = .bpLightBlue
            $0.titleLabel?.font = .notoSansRegular(ofSize: 20)
        }
