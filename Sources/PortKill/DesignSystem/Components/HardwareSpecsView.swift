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
                    HStack(spacing: 4) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(Color.secondary.opacity(0.9))

                        Text(hardware.chipName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    Capsule()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 1, height: 10)

                    Text(hardware.totalMemoryFormatted)
                        .font(Theme.Typography.metaMono)
                        .foregroundStyle(Color.secondary.opacity(0.9))
                        .lineLimit(1)

                    Capsule()
                        .fill(Color.primary.opacity(0.1))
                        .frame(width: 1, height: 10)

                    if let tflops = hardware.tflopsFormatted {
                        Text(tflops)
                            .font(Theme.Typography.metaMono)
                            .foregroundStyle(Color.secondary.opacity(0.9))
                            .lineLimit(1)

                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                            .frame(width: 1, height: 10)
                    }

                    HStack(spacing: 4.5) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.08))
                            Capsule()
                                .fill(cpuGaugeColor)
                                .frame(width: max(2, 22 * CGFloat(min(max(cpuPercent ?? 0, 0), 100) / 100.0)))
                        }
                        .frame(width: 22, height: 4)

                        Text(cpuLabel)
                            .font(Theme.Typography.metaMono)
                            .foregroundStyle(isHighLoad ? Theme.Colors.killRed : Color.secondary.opacity(0.9))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 2)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.secondary.opacity(0.55))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6.5)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .onHover { isHovered = $0 }

            if isExpanded {
                Divider()
                    .overlay(Theme.Colors.rowSeparator)

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
                            icon: nil,
                            title: "COMPUTE",
                            value: tflops,
                            subtitle: "Peak FP32"
                        )
                    }

                    detailTile(
                        icon: "gauge.medium",
                        title: "CPU LOAD",
                        value: cpuLabel,
                        subtitle: isHighLoad ? "High Load" : "Nominal",
                        isAlert: isHighLoad
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .fill(isHovered ? Theme.Colors.cardHover : Theme.Colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium, style: .continuous)
                .stroke(isExpanded ? Theme.Colors.cardBorderActive : Theme.Colors.cardBorder, lineWidth: 1)
        )
    }

    private func detailTile(
        icon: String?,
        title: String,
        value: String,
        subtitle: String,
        isAlert: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3.5) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 8.5, weight: .bold))
            }
            .foregroundStyle(Color.secondary.opacity(0.75))

            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .minimumScaleFactor(0.8)
                .foregroundStyle(isAlert ? Theme.Colors.killRed : Color.primary.opacity(0.92))
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(Color.secondary.opacity(0.75))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 7)
        .padding(.vertical, 5.5)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.primary.opacity(0.035))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.8)
        )
    }

    private var isHighLoad: Bool { (cpuPercent ?? 0) > 70 }

    private var cpuGaugeColor: Color {
        let load = cpuPercent ?? 0
        if load > 75 { return Theme.Colors.killRed }
        if load > 50 { return Theme.Colors.statusWarning }
        return Theme.Colors.statusActive
    }

    private var cpuLabel: String {
        cpuPercent.map { String(format: "%.0f%%", $0) } ?? "–"
    }
}
