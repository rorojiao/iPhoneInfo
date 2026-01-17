import SwiftUI

struct HUDPanel<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color = HUDTheme.rogRed, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(
                LinearGradient(
                    colors: [HUDTheme.panelFillStrong, HUDTheme.panelFill],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                    .stroke(HUDTheme.rogRed.opacity(0.65), lineWidth: HUDTheme.borderWidth)
            )
            .shadow(color: HUDTheme.glowSoft, radius: 14, x: 0, y: 0)
            .cornerRadius(HUDTheme.smallCornerRadius)
    }
}
