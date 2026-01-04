import SwiftUI
import WidgetKit
import Shared

// MARK: - Main Entry View (native glass)
struct ClaudeWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        Group {
            if let snapshot = entry.snapshot {
                switch widgetFamily {
                case .systemSmall:
                    SmallWidget(snapshot: snapshot)
                case .systemMedium:
                    MediumWidget(snapshot: snapshot)
                case .systemLarge, .systemExtraLarge:
                    LargeWidget(snapshot: snapshot)
                @unknown default:
                    EmptyWidget()
                }
            } else {
                EmptyWidget()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 6)
        )
    }
}

// MARK: - Small
struct SmallWidget: View {
    let snapshot: WidgetSnapshot
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Header(title: "Claude usage", timestamp: snapshot.generatedAt)
                MetricRow(label: "Session", percent: snapshot.usage.fiveHour.remainingPercent)
                MetricRow(label: "Weekly", percent: snapshot.usage.sevenDay.remainingPercent)
            }
        }
    }
}

// MARK: - Medium
struct MediumWidget: View {
    let snapshot: WidgetSnapshot
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Header(title: "Claude usage monitor", timestamp: snapshot.generatedAt)
                MetricRow(label: "Session (5h)", percent: snapshot.usage.fiveHour.remainingPercent)
                MetricRow(label: "Weekly (7d)", percent: snapshot.usage.sevenDay.remainingPercent)
                if let billing = snapshot.billing {
                    Divider().opacity(0.3)
                    HStack {
                        Text("Credits")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", billing.dollars)) \(billing.currency)")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                    }
                }
            }
        }
    }
}

// MARK: - Large
struct LargeWidget: View {
    let snapshot: WidgetSnapshot
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Header(title: "Claude usage — live", timestamp: snapshot.generatedAt)
                MetricSection(
                    title: "Session limit (5h)",
                    percent: snapshot.usage.fiveHour.remainingPercent,
                    reset: snapshot.usage.fiveHour.resetsAt
                )
                MetricSection(
                    title: "Weekly limit (7d)",
                    percent: snapshot.usage.sevenDay.remainingPercent,
                    reset: snapshot.usage.sevenDay.resetsAt
                )
                if let billing = snapshot.billing {
                    Divider().opacity(0.3)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Prepaid credits")
                                .font(.system(.callout, design: .rounded).weight(.semibold))
                            Text("Balance")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("$\(String(format: "%.2f", billing.dollars)) \(billing.currency)")
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                    }
                }
                HStack(spacing: 8) {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("Connected")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("// updates every 30m")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Empty
struct EmptyWidget: View {
    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text("Claude usage")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Open the app to refresh")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Components
private struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 6)
            content
                .padding(14)
        }
    }
}

private struct Header: View {
    let title: String
    let timestamp: Date
    var body: some View {
        HStack {
            Text(title)
                .font(.system(.headline, design: .rounded).weight(.semibold))
            Spacer()
            Text(timeAgo(timestamp))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MetricRow: View {
    let label: String
    let percent: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(percent))%")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            ProgressView(value: max(0, min(percent, 100)) / 100)
                .progressViewStyle(.linear)
                .tint(progressTint(for: percent))
        }
    }
    private func progressTint(for value: Double) -> LinearGradient {
        if value < 20 {
            return LinearGradient(colors: [.red.opacity(0.9), .red.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        } else if value < 40 {
            return LinearGradient(colors: [.orange.opacity(0.9), .orange.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        } else {
            return LinearGradient(colors: [.green.opacity(0.9), .green.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
        }
    }
}

private struct MetricSection: View {
    let title: String
    let percent: Double
    let reset: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                Spacer()
                Text("\(String(format: "%.1f", percent))% remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            MetricRow(label: "", percent: percent)
            Text("Resets: \(formatDate(reset))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    private func formatDate(_ date: Date) -> String {
        let fmt = RelativeDateTimeFormatter()
        fmt.unitsStyle = .abbreviated
        return fmt.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Helpers
private func timeAgo(_ date: Date) -> String {
    let fmt = RelativeDateTimeFormatter()
    fmt.unitsStyle = .abbreviated
    return fmt.localizedString(for: date, relativeTo: Date())
}
