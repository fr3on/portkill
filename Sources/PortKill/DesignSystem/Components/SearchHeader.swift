import SwiftUI

struct SearchHeader: View {
    @Binding var query: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isFocused ? Color.primary : .secondary)

            TextField("Search port, process, or project...", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .focused($isFocused)

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                Text("⌘F")
                    .font(Theme.Typography.shortcutGlyph)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: Theme.Dimensions.searchHeight)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Color.primary.opacity(isFocused ? 0.06 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(
                    isFocused ? Color.primary.opacity(0.18) : Color.primary.opacity(0.07),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
