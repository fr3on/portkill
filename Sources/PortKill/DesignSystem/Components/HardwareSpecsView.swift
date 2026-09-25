import SwiftUI

struct HardwareSpecsView: View {
    let cpuPercent: Double?
    @Binding var isExpanded: Bool
    @UIState private var isHovered: Bool = false
    let hardware = SystemHardware.current

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Theme.Spacing.sm) {
                    // Apple logo & chip
                    HStack(spacing: 4.5) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(.secondary)

                        Text(hardware.chipName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    // Vertical divider
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(width: 1, height: 10)

                    // Memory
                    Text(hardware.totalMemoryFormatted)
                        .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    // Vertical divider
                    Capsule()
                        .fill(Color.primary.opacity(0.12))
                        .frame(width: 1, height: 10)

                    // GPU compute estimate, only when we can compute it honestly
                    if let tflops = hardware.tflopsFormatted {
                        HStack(spacing: 3) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(Theme.Colors.statusActive)
                            Text(tflops)
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Theme.Colors.statusActive)
                        }
                        .lineLimit(1)

                        // Vertical divider
                        Capsule()
                            .fill(Color.primary.opacity(0.12))
                            .frame(width: 1, height: 10)
                    }

                    // CPU live load
                    HStack(spacing: 4) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.10))
                            Capsule()
                                .fill(isHighLoad ? Theme.Colors.killRed : Theme.Colors.statusActive)
                                .frame(width: max(2, 20 * CGFloat(min(max(cpuPercent ?? 0, 0), 100) / 100.0)))
                        }
                        .frame(width: 20, height: 4)

                        Text(cpuLabel)
                            .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(isHighLoad ? Theme.Colors.killRed : .secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 2)

                    // Rotating disclosure chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            if isExpanded {
                Divider()
                    .overlay(Color.primary.opacity(0.06))

                HStack(spacing: 6) {
                    detailTile(
                        icon: "cpu",
                        title: "CORES",
                        value: "\(hardware.coreCount)c CPU",
                        subtitle: hardware.gpuCoreCount.map { "\($0)c GPU" } ?? "GPU"
                    )

                    detailTile(
                        icon: "memorychip",
                        title: "RAM",
                        value: hardware.totalMemoryFormatted,
                        subtitle: "Unified"
                    )

                    if let tflops = hardware.tflopsFormatted {
                        detailTile(
                            icon: "bolt.fill",
                            title: "COMPUTE",
                            value: tflops,
                            subtitle: "Est. peak FP32",
                            highlight: true
                        )
                    }

                    detailTile(
                        icon: "gauge.medium",
                        title: "CPU LOAD",
                        value: cpuLabel,
                        subtitle: isHighLoad ? "High" : "Normal",
                        isAlert: isHighLoad
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(Color.primary.opacity(isHovered ? 0.045 : 0.025))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(Color.primary.opacity(isExpanded ? 0.12 : 0.06), lineWidth: 1)
        )
    }

    private func detailTile(
        icon: String,
        title: String,
        value: String,
        subtitle: String,
        highlight: Bool = false,
        isAlert: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 2.5) {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .semibold))
                Text(title)
                    .font(.system(size: 8.5, weight: .semibold))
            }
            .foregroundStyle(.tertiary)

            Text(value)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .minimumScaleFactor(0.75)
                .foregroundStyle(isAlert ? Theme.Colors.killRed : (highlight ? Theme.Colors.statusActive : .primary))
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 5)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.primary.opacity(0.025))
        )
    }

    private var isHighLoad: Bool { (cpuPercent ?? 0) > 70 }

    private var cpuLabel: String {
        cpuPercent.map { String(format: "%.0f%%", $0) } ?? "–"
    }
}
