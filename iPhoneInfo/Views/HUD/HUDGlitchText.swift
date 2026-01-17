import SwiftUI

struct HUDGlitchText: View {
    let text: String
    var tint: Color = HUDTheme.rogRed

    @State private var glitch: CGFloat = 0

    var body: some View {
        ZStack {
            Text(text)
                .foregroundColor(HUDTheme.textPrimary)
                .shadow(color: tint.opacity(0.35), radius: 6, x: 0, y: 0)

            Text(text)
                .foregroundColor(tint.opacity(0.65))
                .offset(x: -glitch, y: 0)
                .blendMode(.screen)

            Text(text)
                .foregroundColor(HUDTheme.rogCyan.opacity(0.45))
                .offset(x: glitch, y: 0)
                .blendMode(.screen)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.12).repeatForever(autoreverses: true)) {
                glitch = 1.4
            }
        }
    }
}
