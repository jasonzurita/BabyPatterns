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

func styleViewBackground(color: UIColor) -> (UIView) -> Void {
    return {
        $0.backgroundColor = color
    }
}

// MARK: Bar Graph Element
let styleBarGraphElementBase: (UIView) -> Void = {
    $0.layer.cornerRadius = 2 // FIXME: this number is an assumption that the width is 4
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
}

let styleBarGraphElementNursing =
    styleBarGraphElementBase
        <> {
            $0.backgroundColor = .bpPink
}

let styleBarGraphElementPumping: (UIView) -> Void =
    styleBarGraphElementBase
        <> {
            $0.backgroundColor = .bpGreen
}

let styleBarGraphElementBottle =
    styleBarGraphElementBase
        <> {
            $0.backgroundColor = .bpMediumBlue
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

let styleLabelP2 =
    styleLabelBase
        <> styleLabelFont(.notoSansRegular(ofSize: 14))
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

func styleButtonRounded(_ color: UIColor) -> (UIButton) -> Void {
    return styleButtonBase
        <> styleButtonCornerRadius
        <> styleButtonFont(.notoSansRegular(ofSize: 20))
        <> {
            $0.backgroundColor = color
    }
}

// MARK: TextFields
let styleTextFieldBase: (UITextField) -> Void = {
    $0.font = .notoSansRegular(ofSize: 16)
    $0.textColor = .bpDarkGray
}
