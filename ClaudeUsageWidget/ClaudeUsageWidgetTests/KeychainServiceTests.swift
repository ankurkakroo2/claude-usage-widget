import XCTest
@testable import Shared

final class KeychainServiceTests: XCTestCase {
    var keychainService: KeychainService!

    override func setUp() {
        super.setUp()
        keychainService = KeychainService.shared
        // Clean up before each test
        try? keychainService.deleteCredentials()
    }

    override func tearDown() {
        // Clean up after each test
        try? keychainService.deleteCredentials()
        super.tearDown()
    }

    func testSaveAndRetrieveSessionCookie() throws {
        // Given
        let testCookie = "test-session-cookie-12345"

        // When
        try keychainService.saveSessionCookie(testCookie)
        let retrieved = try keychainService.getSessionCookie()

        // Then
        XCTAssertEqual(retrieved, testCookie)
    }

    func testSaveAndRetrieveOrganizationId() throws {
        // Given
        let testOrgId = "1710c301-935f-4e92-99aa-6795e3069796"

        // When
        try keychainService.saveOrganizationId(testOrgId)
        let retrieved = try keychainService.getOrganizationId()

        // Then
        XCTAssertEqual(retrieved, testOrgId)
    }

    func testDeleteCredentials() throws {
        // Given
        try keychainService.saveSessionCookie("test-cookie")
        try keychainService.saveOrganizationId("test-org-id")

        // When
        try keychainService.deleteCredentials()

        // Then
        let cookie = try keychainService.getSessionCookie()
        let orgId = try keychainService.getOrganizationId()

        XCTAssertNil(cookie)
        XCTAssertNil(orgId)
    }

    func testRetrieveNonExistentKey() throws {
        // When
        let cookie = try keychainService.getSessionCookie()

        // Then
        XCTAssertNil(cookie)
    }

    func testUpdateExistingKey() throws {
        // Given
        let firstCookie = "first-cookie"
        let secondCookie = "second-cookie"

        // When
        try keychainService.saveSessionCookie(firstCookie)
        try keychainService.saveSessionCookie(secondCookie)
        let retrieved = try keychainService.getSessionCookie()

        // Then
        XCTAssertEqual(retrieved, secondCookie)
    }
}
