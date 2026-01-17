import SwiftUI

struct HUDRingGauge: View {
    let title: String
    let valuePercent: Double
    let subtitle: String
    let tint: Color

    @State private var rotation: Angle = .degrees(0)

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 16)

            Circle()
                .trim(from: 0, to: max(0, min(1, valuePercent / 100.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [tint.opacity(0.15), tint, HUDTheme.neonRed.opacity(0.7)]),
                        center: .center,
                        angle: rotation
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.45), radius: 12, x: 0, y: 0)
                .shadow(color: HUDTheme.neonRed.opacity(0.3), radius: 18, x: 0, y: 0)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: valuePercent)

            Circle()
                .trim(from: 0, to: 1)
                .stroke(tint.opacity(0.08), style: StrokeStyle(lineWidth: 6, lineCap: .round, dash: [6, 10]))
                .rotationEffect(rotation)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))

                Text("\(Int(valuePercent))%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 5.2).repeatForever(autoreverses: false)) {
                rotation = .degrees(360)
            }
        }
    }
}
