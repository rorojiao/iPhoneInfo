import SwiftUI

struct HUDRadarSweep: View {
    var tint: Color = HUDTheme.neonCyan
    var opacity: Double = 0.10

    @State private var angle: Angle = .degrees(0)

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let radius = min(size.width, size.height) * 0.6

            ZStack {
                Circle()
                    .stroke(tint.opacity(0.14), lineWidth: 1)

                Circle()
                    .trim(from: 0, to: 0.14)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [tint.opacity(0.0), tint.opacity(opacity), tint.opacity(0.0)]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: radius, lineCap: .butt)
                    )
                    .rotationEffect(angle)
                    .blur(radius: 12)
                    .blendMode(.screen)
            }
            .frame(width: radius * 2, height: radius * 2)
            .position(x: size.width / 2, y: size.height / 2)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.linear(duration: 3.2).repeatForever(autoreverses: false)) {
                    angle = .degrees(360)
                }
            }
        }
    }
}
