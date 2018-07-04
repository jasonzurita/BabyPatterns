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

// MARK: UIView
let styleViewBorder: (UIView) -> Void = {
    $0.layer.borderColor = UIColor.bpMediumBlue.cgColor
    $0.layer.masksToBounds = true
}

// MARK: Label Styles
let styleLabelBase: (UILabel) -> Void = {
    $0.numberOfLines = 0
    $0.backgroundColor = .clear
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

let styleLabelTitle =
    styleLabelBase
        <> styleLabelFont(.notoSansBold(ofSize: 35))
        <> styleLabelColor(.bpWhite)

let styleLabelH2 =
    styleLabelBase
        <> styleLabelFont(.notoSansBold(ofSize: 16))
        <> styleLabelColor(.bpMediumGray)

let styleLabelBody =
    styleLabelBase
        <> styleLabelFont(.notoSansRegular(ofSize: 16))
        <> styleLabelColor(.bpMediumGray)

let styleLabelTimer =
    styleLabelBase
        <> styleLabelColor(.bpMediumGray)
        <> styleLabelFont(.notoSansBold(ofSize: 46))
        <> {
            $0.textAlignment = .center
}

// MARK: Buttons
let styleButtonBase: (UIButton) -> Void = { _ in
    // noop
}

let styleButtonCornerRadius: (UIButton) -> Void = {
    $0.layer.cornerRadius = $0.frame.height * 0.5
    $0.layer.masksToBounds = true
}

func styleButtonFont(_ font: UIFont) -> (UIButton) -> Void {
    return {
        $0.titleLabel?.font = font
    }
}

let styleButtonSave =
    styleButtonBase
        <> styleButtonCornerRadius
        <> styleButtonFont(.notoSansRegular(ofSize: 20))
        <> {
            $0.backgroundColor = .bpLightBlue
        }
