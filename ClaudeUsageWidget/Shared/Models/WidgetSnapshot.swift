import Foundation

public struct WidgetSnapshot: Codable, Sendable {
    public let usage: UsageData
    public let billing: BillingData?
    public let generatedAt: Date

    public var isStale: Bool {
        let staleDuration: TimeInterval = 15 * 60 // 15 minutes
        return Date().timeIntervalSince(generatedAt) > staleDuration
    }

    public init(usage: UsageData, billing: BillingData?, generatedAt: Date) {
        self.usage = usage
        self.billing = billing
        self.generatedAt = generatedAt
    }
}
