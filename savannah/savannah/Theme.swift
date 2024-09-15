import SwiftUI

// Custom Colors


// Custom Fonts
extension Font {
    static func systemSansSerif(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func systemSerif(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
}

// Font Modifier
struct CustomFontModifier: ViewModifier {
    enum FontStyle {
        case body, title, headline, subheadline
    }
    
    let style: FontStyle
    
    func body(content: Content) -> some View {
        switch style {
        case .body:
            content.font(.systemSansSerif(size: 16))
        case .title:
            content.font(.systemSerif(size: 24))
        case .headline:
            content.font(.systemSansSerif(size: 18))
        case .subheadline:
            content.font(.systemSansSerif(size: 14))
        }
    }
}

extension View {
    func customFont(_ style: CustomFontModifier.FontStyle) -> some View {
        self.modifier(CustomFontModifier(style: style))
    }
}
