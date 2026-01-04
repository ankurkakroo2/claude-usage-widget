import XCTest
@testable import Shared

final class EndToEndTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Clean slate before each test
        try? KeychainService.shared.deleteCredentials()
        StorageService.shared.clearAll()
    }

    override func tearDown() {
        // Clean up after each test
        try? KeychainService.shared.deleteCredentials()
        StorageService.shared.clearAll()
        super.tearDown()
    }

    func testCompleteDataFlow() throws {
        // This test verifies the complete flow:
        // 1. Save credentials to Keychain
        // 2. Save usage data to Storage
        // 3. Retrieve data from Storage
        // 4. Verify data integrity

        // Given
        let testOrgId = "test-org-123"
        let testCookie = "test-cookie-456"

        let usageData = UsageData(
            fiveHour: UsageData.UsagePeriod(
                utilization: 80.0,
                resetsAt: Date().addingTimeInterval(3600)
            ),
            sevenDay: UsageData.UsagePeriod(
                utilization: 55.0,
                resetsAt: Date().addingTimeInterval(86400)
            )
        )

        let billingData = BillingData(
            amount: 2500,
            currency: "USD"
        )

        // When - Save credentials
        try KeychainService.shared.saveOrganizationId(testOrgId)
        try KeychainService.shared.saveSessionCookie(testCookie)

        // When - Save data
        try StorageService.shared.saveUsageData(usageData)
        try StorageService.shared.saveBillingData(billingData)

        // Then - Verify credentials
        let retrievedOrgId = try KeychainService.shared.getOrganizationId()
        let retrievedCookie = try KeychainService.shared.getSessionCookie()

        XCTAssertEqual(retrievedOrgId, testOrgId)
        XCTAssertEqual(retrievedCookie, testCookie)

        // Then - Verify data
        let retrievedUsage = StorageService.shared.loadUsageData()
        let retrievedBilling = StorageService.shared.loadBillingData()

        XCTAssertNotNil(retrievedUsage)
        XCTAssertNotNil(retrievedBilling)
        XCTAssertEqual(retrievedUsage?.fiveHour.utilization, 80.0)
        XCTAssertEqual(retrievedBilling?.dollars, 25.0)
    }

    func testCredentialRefresh() throws {
        // Given - Initial credentials
        try KeychainService.shared.saveOrganizationId("old-org-id")
        try KeychainService.shared.saveSessionCookie("old-cookie")

        // When - Update credentials
        try KeychainService.shared.saveOrganizationId("new-org-id")
        try KeychainService.shared.saveSessionCookie("new-cookie")

        // Then - Verify new credentials
        let orgId = try KeychainService.shared.getOrganizationId()
        let cookie = try KeychainService.shared.getSessionCookie()

        XCTAssertEqual(orgId, "new-org-id")
        XCTAssertEqual(cookie, "new-cookie")
    }

    func testOfflineMode() throws {
        // This test verifies that the app can work with cached data
        // when network is unavailable

        // Given - Cached data
        let cachedUsage = UsageData(
            fiveHour: UsageData.UsagePeriod(utilization: 60, resetsAt: Date()),
            sevenDay: UsageData.UsagePeriod(utilization: 40, resetsAt: Date())
        )

        try StorageService.shared.saveUsageData(cachedUsage)

        // When - Load from cache (simulating offline mode)
        let loaded = StorageService.shared.loadUsageData()

        // Then - Verify cached data is available
        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.fiveHour.utilization, 60)
    }

    func testAuthServiceIntegration() async throws {
        // This test verifies AuthService integration with KeychainService

        // Given - No credentials
        XCTAssertFalse(AuthService.shared.hasValidCredentials())

        // When - Save credentials (without validation since we don't have real API)
        try KeychainService.shared.saveOrganizationId("test-org")
        try KeychainService.shared.saveSessionCookie("test-cookie")

        // Then - Should have credentials
        XCTAssertTrue(AuthService.shared.hasValidCredentials())

        // When - Clear credentials
        try AuthService.shared.clearCredentials()

        // Then - Should not have credentials
        XCTAssertFalse(AuthService.shared.hasValidCredentials())
    }
}
