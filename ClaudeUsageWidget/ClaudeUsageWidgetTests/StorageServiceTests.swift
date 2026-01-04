import XCTest
@testable import Shared

final class StorageServiceTests: XCTestCase {
    var storageService: StorageService!

    override func setUp() {
        super.setUp()
        storageService = StorageService.shared
        storageService.clearAll()
    }

    override func tearDown() {
        storageService.clearAll()
        super.tearDown()
    }

    func testSaveAndLoadUsageData() throws {
        // Given
        let usageData = UsageData(
            fiveHour: UsageData.UsagePeriod(
                utilization: 75.0,
                resetsAt: Date().addingTimeInterval(3600)
            ),
            sevenDay: UsageData.UsagePeriod(
                utilization: 45.0,
                resetsAt: Date().addingTimeInterval(86400)
            ),
            lastUpdated: Date()
        )

        // When
        try storageService.saveUsageData(usageData)
        let loaded = storageService.loadUsageData()

        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.fiveHour.utilization, 75.0)
        XCTAssertEqual(loaded?.sevenDay.utilization, 45.0)
    }

    func testSaveAndLoadBillingData() throws {
        // Given
        let billingData = BillingData(
            amount: 1250, // $12.50
            currency: "USD",
            autoReloadSettings: nil,
            lastUpdated: Date()
        )

        // When
        try storageService.saveBillingData(billingData)
        let loaded = storageService.loadBillingData()

        // Then
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.amount, 1250)
        XCTAssertEqual(loaded?.currency, "USD")
        XCTAssertEqual(loaded?.dollars, 12.50)
    }

    func testLoadNonExistentData() {
        // When
        let usageData = storageService.loadUsageData()
        let billingData = storageService.loadBillingData()

        // Then
        XCTAssertNil(usageData)
        XCTAssertNil(billingData)
    }

    func testRefreshInterval() {
        // Given
        let interval: TimeInterval = 600 // 10 minutes

        // When
        storageService.saveRefreshInterval(interval)
        let loaded = storageService.getRefreshInterval()

        // Then
        XCTAssertEqual(loaded, interval)
    }

    func testDefaultRefreshInterval() {
        // When
        let interval = storageService.getRefreshInterval()

        // Then
        XCTAssertEqual(interval, 300) // Default 5 minutes
    }

    func testClearAll() throws {
        // Given
        let usageData = UsageData(
            fiveHour: UsageData.UsagePeriod(utilization: 50, resetsAt: Date()),
            sevenDay: UsageData.UsagePeriod(utilization: 30, resetsAt: Date())
        )
        let billingData = BillingData(amount: 1000, currency: "USD")

        try storageService.saveUsageData(usageData)
        try storageService.saveBillingData(billingData)

        // When
        storageService.clearAll()

        // Then
        XCTAssertNil(storageService.loadUsageData())
        XCTAssertNil(storageService.loadBillingData())
    }
}
