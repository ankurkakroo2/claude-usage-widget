import XCTest
@testable import Shared

final class ClaudeAPIServiceTests: XCTestCase {
    var apiService: ClaudeAPIService!

    override func setUp() {
        super.setUp()
        apiService = ClaudeAPIService.shared
    }

    func testFetchUsageWithInvalidCredentials() async {
        // Given
        let invalidOrgId = "invalid-org-id"
        let invalidCookie = "invalid-cookie"

        // When/Then
        do {
            _ = try await apiService.fetchUsage(orgId: invalidOrgId, cookie: invalidCookie)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected to fail with unauthorized or network error
            XCTAssertTrue(error is ClaudeAPIService.APIError)
        }
    }

    func testFetchBillingWithInvalidCredentials() async {
        // Given
        let invalidOrgId = "invalid-org-id"
        let invalidCookie = "invalid-cookie"

        // When/Then
        do {
            _ = try await apiService.fetchBilling(orgId: invalidOrgId, cookie: invalidCookie)
            XCTFail("Should have thrown an error")
        } catch {
            // Expected to fail with unauthorized or network error
            XCTAssertTrue(error is ClaudeAPIService.APIError)
        }
    }

    func testFetchAllDataWithoutCredentials() async {
        // Given - no credentials stored
        try? KeychainService.shared.deleteCredentials()

        // When/Then
        do {
            _ = try await apiService.fetchAllData()
            XCTFail("Should have thrown missing credentials error")
        } catch ClaudeAPIService.APIError.missingCredentials {
            // Expected
            XCTAssertTrue(true)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // Note: Real API tests would require valid credentials
    // These tests verify error handling and structure
}
