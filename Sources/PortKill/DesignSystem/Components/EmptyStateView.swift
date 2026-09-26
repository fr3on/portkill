import SwiftUI

struct EmptyStateView: View {
    let query: String

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.035))
                    .frame(width: 52, height: 52)

                Circle()
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                    .frame(width: 52, height: 52)

                Image(systemName: query.isEmpty ? "bolt.slash" : "magnifyingglass")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Color.secondary.opacity(0.7))
            }

            VStack(spacing: 5) {
                Text(query.isEmpty ? "No active dev servers" : "No results for \"\(query)\"")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Text(query.isEmpty
                     ? "Start a server (e.g. npm run dev or python -m http.server) and it will appear here."
                     : "Try searching by another port number, process name, or project.")
                    .font(.system(size: 11.5))
                    .foregroundStyle(Color.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xl)
            }
        }
        .padding(.vertical, Theme.Spacing.xxl)
        .frame(maxWidth: .infinity)
    }
}
