import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        #if canImport(UIKit)
        if #available(iOS 15.0, *) {
            // Use the new method for iOS 15 and later
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                return window.safeAreaInsets.insets
            }
        } else {
            // Fallback for earlier iOS versions
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                return keyWindow.safeAreaInsets.insets
            }
        }
        #endif
        return EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

#if canImport(UIKit)
private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
#endif

// Helper for previews
extension View {
    func withPreviewSafeAreaInsets(_ insets: EdgeInsets = EdgeInsets(top: 47, leading: 0, bottom: 34, trailing: 0)) -> some View {
        environment(\.safeAreaInsets, insets)
    }
}