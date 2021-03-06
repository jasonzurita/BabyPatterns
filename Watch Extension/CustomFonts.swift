import SwiftUI

// TODO: put into common SPM when SPM supports assets
public enum CustomFont: String {
    case notoSansBold = "NotoSans-Bold"
    case notoSansSemiBold = "NotoSans-SemiBold"
    case notoSansBoldItalic = "NotoSans-BoldItalic"
    case notoSansItalic = "NotoSans-Italic"
    case notoSansRegular = "NotoSans-Regular"
}

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

extension View {
    func scaledFont(_ name: String, size: CGFloat) -> some View {
        modifier(ScaledFont(name: name, size: size))
    }

    func scaledFont(_ font: CustomFont, size: CGFloat) -> some View {
        scaledFont(font.rawValue, size: size)
    }
}
