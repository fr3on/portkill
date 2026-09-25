import SwiftUI

struct EmptyStateView: View {
    let query: String

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.03))
                    .frame(width: 48, height: 48)

                Image(systemName: query.isEmpty ? "bolt.slash" : "magnifyingglass")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(.tertiary)
            }

            VStack(spacing: Theme.Spacing.xs) {
                Text(query.isEmpty ? "No active dev servers" : "No results for \"\(query)\"")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.primary)

                Text(query.isEmpty
                     ? "Start a server (e.g. npm run dev or python -m http.server) and it will appear here."
                     : "Try searching by another port number, process name, or project.")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
            }
        }
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
