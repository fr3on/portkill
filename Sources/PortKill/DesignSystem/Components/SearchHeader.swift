import SwiftUI

struct SearchHeader: View {
    @Binding var query: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(isFocused.wrappedValue ? Color.accentColor : Color.secondary.opacity(0.8))

            TextField("Search port, process, or project...", text: $query)
                .textFieldStyle(.plain)
                .font(.system(size: 12, weight: .regular))
                .focused(isFocused)
                .onKeyPress(.escape) {
                    if query.isEmpty {
                        isFocused.wrappedValue = false
                        return .ignored
                    }
                    query = ""
                    return .handled
                }

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("Clear search")
                .transition(.scale.combined(with: .opacity))
            } else {
                Text("⌘F")
                    .font(Theme.Typography.shortcutGlyph)
                    .foregroundStyle(Color.secondary.opacity(0.8))
                    .padding(.horizontal, 4.5)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                            )
                    )
            }
        }
        .padding(.horizontal, Theme.Spacing.md + 1)
        .frame(height: Theme.Dimensions.searchHeight)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Color.primary.opacity(isFocused.wrappedValue ? 0.07 : 0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(
                    isFocused.wrappedValue ? Color.accentColor.opacity(0.45) : Color.primary.opacity(0.08),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.16), value: isFocused.wrappedValue)
    }
}
