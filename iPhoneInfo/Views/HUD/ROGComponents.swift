import SwiftUI

struct ROGPage<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ZStack {
            HUDBg()

            VStack(spacing: 14) {
                ROGHeaderBar(title: title)
                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }
}

struct ROGHeaderBar: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(HUDTheme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 2)
    }
}

struct ROGCard<Content: View>: View {
    let title: String?
    let accent: Color
    let content: Content

    init(title: String? = nil, accent: Color = HUDTheme.rogRed, @ViewBuilder content: () -> Content) {
        self.title = title
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(HUDTheme.textPrimary)
            }

            content
        }
        .padding(14)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.cornerRadius)
                .stroke(accent.opacity(0.75), lineWidth: HUDTheme.borderWidth)
        )
        .shadow(color: accent.opacity(0.20), radius: 14, x: 0, y: 0)
        .overlay(HUDScanlineOverlay(opacity: 0.04))
        .cornerRadius(HUDTheme.cornerRadius)
    }
}

struct ROGSegmentedPicker<Selection: Hashable>: View {
    let title: String
    @Binding var selection: Selection
    let items: [(Selection, String)]

    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(items, id: \.0) { value, label in
                Text(label).tag(value)
            }
        }
        .pickerStyle(.segmented)
        .padding(10)
        .background(Color.black.opacity(0.55))
        .overlay(
            RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                .stroke(HUDTheme.borderSoft, lineWidth: HUDTheme.borderWidth)
        )
        .overlay(HUDScanlineOverlay(opacity: 0.03))
        .cornerRadius(HUDTheme.smallCornerRadius)
    }
}

struct ROGRedActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            .foregroundColor(HUDTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: HUDTheme.primaryButtonHeight)
            .padding(.horizontal, 14)
            .background(
                LinearGradient(
                    colors: [HUDTheme.rogRedDeep, HUDTheme.rogRed],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HUDTheme.smallCornerRadius)
                    .stroke(HUDTheme.borderStrong, lineWidth: HUDTheme.borderWidth)
            )
            .shadow(color: HUDTheme.glowStrong, radius: 18, x: 0, y: 0)
            .cornerRadius(HUDTheme.smallCornerRadius)
        }
        .buttonStyle(.plain)
    }
}

struct ROGValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(HUDTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(HUDTheme.textPrimary)
        }
    }
}
