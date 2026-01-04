import Foundation

public final class StorageService: @unchecked Sendable {
    public static let shared = StorageService()

    private let suiteName = "group.com.claude.usagewidget"
    private let snapshotKey = "widget_snapshot"
    private let sessionKeyKey = "session_key_source"
    private let orgIdKey = "organization_id"

    private init() {}

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Widget Snapshot

    public func saveSnapshot(_ snapshot: WidgetSnapshot) {
        guard let defaults = defaults else {
            print("❌ Failed to access UserDefaults with suite: \(suiteName)")
            return
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(snapshot) {
            defaults.set(data, forKey: snapshotKey)
            defaults.synchronize()
            print("✅ Saved snapshot to UserDefaults")
        } else {
            print("❌ Failed to encode snapshot")
        }
    }

    public func loadSnapshot() -> WidgetSnapshot? {
        guard let defaults = defaults,
              let data = defaults.data(forKey: snapshotKey) else {
            print("⚠️ No snapshot found in UserDefaults")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let snapshot = try? decoder.decode(WidgetSnapshot.self, from: data) {
            print("✅ Loaded snapshot from UserDefaults")
            return snapshot
        } else {
            print("❌ Failed to decode snapshot")
            return nil
        }
    }

    // MARK: - Session Key Source

    public func saveSessionKeySource(_ source: String) {
        defaults?.set(source, forKey: sessionKeyKey)
        defaults?.synchronize()
    }

    public func loadSessionKeySource() -> String? {
        defaults?.string(forKey: sessionKeyKey)
    }

    // MARK: - Organization ID

    public func saveOrganizationId(_ id: String) {
        defaults?.set(id, forKey: orgIdKey)
        defaults?.synchronize()
    }

    public func loadOrganizationId() -> String? {
        defaults?.string(forKey: orgIdKey)
    }

    // MARK: - Clear All

    public func clearAll() {
        defaults?.removeObject(forKey: snapshotKey)
        defaults?.removeObject(forKey: sessionKeyKey)
        defaults?.removeObject(forKey: orgIdKey)
        defaults?.synchronize()
    }
}
