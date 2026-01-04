import Foundation

public struct UsageData: Codable, Sendable {
    public let fiveHour: UsagePeriod
    public let sevenDay: UsagePeriod
    public let lastUpdated: Date

    public struct UsagePeriod: Codable, Sendable {
        public let utilization: Double  // 0-100
        public let resetsAt: Date

        public var remainingPercent: Double {
            max(0, 100 - utilization)
        }

        public var isExhausted: Bool {
            utilization >= 100
        }

        public var isLow: Bool {
            remainingPercent < 20
        }

        public init(utilization: Double, resetsAt: Date) {
            self.utilization = utilization
            self.resetsAt = resetsAt
        }
    }

    public init(fiveHour: UsagePeriod, sevenDay: UsagePeriod, lastUpdated: Date) {
        self.fiveHour = fiveHour
        self.sevenDay = sevenDay
        self.lastUpdated = lastUpdated
    }
}
