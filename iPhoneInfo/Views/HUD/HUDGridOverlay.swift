import SwiftUI

struct HUDGridOverlay: View {
    var tint: Color = HUDTheme.neonCyan
    var opacity: Double = 0.06

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            Canvas { context, _ in
                var path = Path()
                let step: CGFloat = 24

                var x: CGFloat = 0
                while x < size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += step
                }

                var y: CGFloat = 0
                while y < size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += step
                }

                context.stroke(path, with: .color(tint.opacity(opacity)), lineWidth: 1)
            }
            .blendMode(.screen)
            .allowsHitTesting(false)
        }
    }
}
