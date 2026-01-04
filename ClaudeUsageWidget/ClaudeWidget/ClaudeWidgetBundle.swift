import WidgetKit
import SwiftUI
import Shared

@main
struct ClaudeWidgetBundle: WidgetBundle {
    var body: some Widget {
        ClaudeUsageWidget()
    }
}

struct ClaudeUsageWidget: Widget {
    let kind: String = "ClaudeUsageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ClaudeWidgetEntryView(entry: entry)
                // Keep our own background so transparent widgets still show content
                .background(TerminalTheme.background)
        }
        .configurationDisplayName("Claude Usage")
        .description("Terminal-style widget showing your Claude API usage limits.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    ClaudeUsageWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: PreviewData.snapshot)
    SimpleEntry(date: .now, snapshot: PreviewData.snapshotLow)
}

#Preview(as: .systemMedium) {
    ClaudeUsageWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: PreviewData.snapshot)
}

#Preview(as: .systemLarge) {
    ClaudeUsageWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: PreviewData.snapshot)
}

// MARK: - Preview Data

enum PreviewData {
    static var snapshot: WidgetSnapshot {
        WidgetSnapshot(
            usage: UsageData(
                fiveHour: UsageData.UsagePeriod(
                    utilization: 65.0,
                    resetsAt: Date().addingTimeInterval(4 * 3600)
                ),
                sevenDay: UsageData.UsagePeriod(
                    utilization: 40.0,
                    resetsAt: Date().addingTimeInterval(3 * 24 * 3600)
                ),
                lastUpdated: Date()
            ),
            billing: BillingData(
                amount: 669,
                currency: "USD",
                autoReloadSettings: nil,
                lastUpdated: Date()
            ),
            generatedAt: Date().addingTimeInterval(-120)
        )
    }

    static var snapshotLow: WidgetSnapshot {
        WidgetSnapshot(
            usage: UsageData(
                fiveHour: UsageData.UsagePeriod(
                    utilization: 95.0,
                    resetsAt: Date().addingTimeInterval(1 * 3600)
                ),
                sevenDay: UsageData.UsagePeriod(
                    utilization: 85.0,
                    resetsAt: Date().addingTimeInterval(2 * 24 * 3600)
                ),
                lastUpdated: Date()
            ),
            billing: BillingData(
                amount: 150,
                currency: "USD",
                autoReloadSettings: nil,
                lastUpdated: Date()
            ),
            generatedAt: Date().addingTimeInterval(-60)
        )
    }
}
