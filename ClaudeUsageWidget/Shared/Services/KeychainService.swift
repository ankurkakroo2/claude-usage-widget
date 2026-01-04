import Foundation
import Security

public final class KeychainService: @unchecked Sendable {
    public static let shared = KeychainService()

    private let serviceName = "com.yourname.claude-usage-widget"
    private let sessionKeyAccount = "claude_session_key"

    private init() {}

    public enum KeychainError: Error {
        case saveFailed(OSStatus)
        case loadFailed(OSStatus)
        case notFound
        case invalidData
    }

    // MARK: - Session Key

    public func saveSessionKey(_ key: String) throws {
        guard let data = key.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: sessionKeyAccount,
            kSecValueData as String: data
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            print("✅ Saved session key to Keychain")
        } else {
            print("❌ Failed to save session key: \(status)")
            throw KeychainError.saveFailed(status)
        }
    }

    public func loadSessionKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: sessionKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.loadFailed(status)
        }

        guard let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        print("✅ Loaded session key from Keychain")
        return key
    }

    public func deleteSessionKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: sessionKeyAccount
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("✅ Deleted session key from Keychain")
        }
    }

    public func hasSessionKey() -> Bool {
        do {
            _ = try loadSessionKey()
            return true
        } catch {
            return false
        }
    }
}
