import SwiftUI

struct HUDBg: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [HUDTheme.backgroundTop, HUDTheme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HUDCircuitOverlay(tint: HUDTheme.rogCyan, accent: HUDTheme.rogRed)
                .opacity(0.55)
                .blendMode(BlendMode.screen)
                .ignoresSafeArea()

            HUDScanlineOverlay(opacity: 0.06)
                .ignoresSafeArea()

            HUDNoiseOverlay(opacity: 0.045)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false) // 确保背景不阻止触摸事件
    }
}
