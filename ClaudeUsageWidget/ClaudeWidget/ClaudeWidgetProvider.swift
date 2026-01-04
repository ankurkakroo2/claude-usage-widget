import WidgetKit
import SwiftUI
import Shared

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            snapshot: WidgetSnapshot(
                usage: UsageData(
                    fiveHour: UsageData.UsagePeriod(utilization: 35.0, resetsAt: Date()),
                    sevenDay: UsageData.UsagePeriod(utilization: 60.0, resetsAt: Date()),
                    lastUpdated: Date()
                ),
                billing: nil,
                generatedAt: Date()
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let snapshot = loadSnapshot()
        let entry = SimpleEntry(date: Date(), snapshot: snapshot)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let snapshot = loadSnapshot()
        let entry = SimpleEntry(date: Date(), snapshot: snapshot)

        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    // MARK: - Storage

    private func loadSnapshot() -> WidgetSnapshot? {
        return StorageService.shared.loadSnapshot()
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}
