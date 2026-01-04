import Foundation

public struct BillingData: Codable, Sendable {
    public let amount: Int  // cents
    public let currency: String
    public let autoReloadSettings: AutoReload?
    public let lastUpdated: Date

    public var dollars: Double {
        Double(amount) / 100.0
    }

    public struct AutoReload: Codable, Sendable {
        public let enabled: Bool
        public let threshold: Int?
        public let amount: Int?

        public init(enabled: Bool, threshold: Int?, amount: Int?) {
            self.enabled = enabled
            self.threshold = threshold
            self.amount = amount
        }
    }

    public init(amount: Int, currency: String, autoReloadSettings: AutoReload?, lastUpdated: Date) {
        self.amount = amount
        self.currency = currency
        self.autoReloadSettings = autoReloadSettings
        self.lastUpdated = lastUpdated
    }
}
