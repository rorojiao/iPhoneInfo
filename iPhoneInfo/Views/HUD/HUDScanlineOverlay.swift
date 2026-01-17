import SwiftUI

struct HUDScanlineOverlay: View {
    var opacity: Double = 0.10

    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            Canvas { context, _ in
                let lineHeight: CGFloat = 2
                let gap: CGFloat = 8
                var y: CGFloat = -size.height + phase

                while y < size.height {
                    let rect = CGRect(x: 0, y: y, width: size.width, height: lineHeight)
                    context.fill(Path(rect), with: .color(Color.white.opacity(opacity)))
                    y += (lineHeight + gap)
                }
            }
            .blendMode(.overlay)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.linear(duration: 2.2).repeatForever(autoreverses: false)) {
                    phase = size.height * 2
                }
            }
        }
    }
}
