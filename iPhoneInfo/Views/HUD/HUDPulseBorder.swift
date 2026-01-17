import SwiftUI

struct HUDPulseBorder: ViewModifier {
    let tint: Color
    let cornerRadius: CGFloat

    @State private var pulse: CGFloat = 0.0

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(tint.opacity(0.75), lineWidth: HUDTheme.borderWidth)
                    .shadow(color: tint.opacity(0.35), radius: 18, x: 0, y: 0)
                    .shadow(color: HUDTheme.cyanGlow, radius: 10, x: 0, y: 0)
                    .opacity(0.55 + (pulse * 0.35))
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = 1
                }
            }
    }
}

extension View {
    func hudPulseBorder(tint: Color = HUDTheme.rogRed, cornerRadius: CGFloat = HUDTheme.smallCornerRadius) -> some View {
        modifier(HUDPulseBorder(tint: tint, cornerRadius: cornerRadius))
    }
}
