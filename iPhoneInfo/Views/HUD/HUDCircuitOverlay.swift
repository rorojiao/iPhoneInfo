import SwiftUI

struct HUDCircuitOverlay: View {
    var tint: Color = HUDTheme.rogCyan
    var accent: Color = HUDTheme.rogRed

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            Canvas { context, _ in
                var path = Path()

                // Horizontal trunk lines
                let y1 = size.height * 0.26
                let y2 = size.height * 0.50
                let y3 = size.height * 0.72

                path.move(to: CGPoint(x: 0, y: y1))
                path.addLine(to: CGPoint(x: size.width, y: y1))

                path.move(to: CGPoint(x: 0, y: y2))
                path.addLine(to: CGPoint(x: size.width, y: y2))

                path.move(to: CGPoint(x: 0, y: y3))
                path.addLine(to: CGPoint(x: size.width, y: y3))

                // Vertical branches
                for xRatio in [0.12, 0.28, 0.48, 0.66, 0.82] {
                    let x = size.width * xRatio
                    path.move(to: CGPoint(x: x, y: y1 - 46))
                    path.addLine(to: CGPoint(x: x, y: y1 + 46))

                    path.move(to: CGPoint(x: x, y: y2 - 60))
                    path.addLine(to: CGPoint(x: x, y: y2 + 60))
                }

                context.stroke(path, with: .color(tint.opacity(0.25)), lineWidth: 1)

                // Nodes
                var nodes = Path()
                let dotSize: CGFloat = 4
                for (i, xRatio) in [0.12, 0.28, 0.48, 0.66, 0.82].enumerated() {
                    let x = size.width * xRatio
                    let color = i % 2 == 0 ? accent : tint

                    nodes.addEllipse(in: CGRect(x: x - dotSize / 2, y: y1 - dotSize / 2, width: dotSize, height: dotSize))
                    nodes.addEllipse(in: CGRect(x: x - dotSize / 2, y: y2 - dotSize / 2, width: dotSize, height: dotSize))

                    context.fill(nodes, with: .color(color.opacity(0.35)))
                    nodes = Path()
                }

                // Corner accents
                let accentRect = CGRect(x: size.width * 0.62, y: size.height * 0.08, width: size.width * 0.3, height: size.height * 0.18)
                context.stroke(Path(roundedRect: accentRect, cornerRadius: 12), with: .color(accent.opacity(0.25)), lineWidth: 1)

                let accentRect2 = CGRect(x: size.width * 0.08, y: size.height * 0.64, width: size.width * 0.32, height: size.height * 0.2)
                context.stroke(Path(roundedRect: accentRect2, cornerRadius: 12), with: .color(tint.opacity(0.22)), lineWidth: 1)
            }
            .allowsHitTesting(false)
        }
    }
}
