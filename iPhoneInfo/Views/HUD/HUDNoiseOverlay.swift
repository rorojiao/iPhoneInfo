import SwiftUI

struct HUDNoiseOverlay: View {
    var opacity: Double = 0.06

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate

                var path = Path()
                let step: CGFloat = 6
                let dot: CGFloat = 1.0

                var y: CGFloat = 0
                while y < size.height {
                    var x: CGFloat = 0
                    while x < size.width {
                        let v = noise(x: x, y: y, t: t)
                        if v > 0.75 {
                            path.addRect(CGRect(x: x, y: y, width: dot, height: dot))
                        }
                        x += step
                    }
                    y += step
                }

                context.fill(path, with: .color(Color.white.opacity(opacity)))
            }
            .blendMode(.overlay)
            .allowsHitTesting(false)
        }
    }

    private func noise(x: CGFloat, y: CGFloat, t: TimeInterval) -> Double {
        let ix = Int(x * 10)
        let iy = Int(y * 10)
        let it = Int(t * 12)
        var seed = UInt64(bitPattern: Int64(ix &* 73856093 ^ iy &* 19349663 ^ it &* 83492791))
        seed ^= seed >> 33
        seed &*= 0xff51afd7ed558ccd
        seed ^= seed >> 33
        seed &*= 0xc4ceb9fe1a85ec53
        seed ^= seed >> 33
        let v = Double(seed % 10_000) / 10_000.0
        return v
    }
}
