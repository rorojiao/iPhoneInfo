import SwiftUI

struct HUDRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .shadow(color: HUDTheme.neonRed.opacity(0.2), radius: 4, x: 0, y: 0)
        }
        .font(.subheadline)
    }
}
