import Foundation

public final class ClaudeAPIService: @unchecked Sendable {
    public static let shared = ClaudeAPIService()

    private let baseURL = "https://claude.ai/api"

    private init() {}

    public enum APIError: LocalizedError {
        case invalidURL
        case invalidResponse
        case unauthorized
        case serverError(Int)
        case noOrganization
        case networkError(Error)

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .invalidResponse:
                return "Invalid response from Claude API"
            case .unauthorized:
                return "Unauthorized. Your session may have expired. Please update your session key."
            case .serverError(let code):
                return "Server error: HTTP \(code)"
            case .noOrganization:
                return "No organization found for this account"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Fetch Organization ID

    public func fetchOrganizationId(sessionKey: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/organizations") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        print("🌐 Fetching organization ID...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("📥 Organizations API status: \(httpResponse.statusCode)")

            switch httpResponse.statusCode {
            case 200:
                let orgs = try JSONDecoder().decode([Organization].self, from: data)
                guard let firstOrg = orgs.first else {
                    throw APIError.noOrganization
                }
                print("✅ Found organization: \(firstOrg.uuid)")
                return firstOrg.uuid

            case 401, 403:
                throw APIError.unauthorized

            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Fetch Usage Data

    public func fetchUsage(organizationId: String, sessionKey: String) async throws -> UsageData {
        guard let url = URL(string: "\(baseURL)/organizations/\(organizationId)/usage") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        print("🌐 Fetching usage data...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("📥 Usage API status: \(httpResponse.statusCode)")

            switch httpResponse.statusCode {
            case 200:
                let usageResponse = try JSONDecoder().decode(APIUsageResponse.self, from: data)
                let usage = try parseUsageResponse(usageResponse)
                print("✅ Fetched usage: Session \(Int(usage.fiveHour.remainingPercent))%, Weekly \(Int(usage.sevenDay.remainingPercent))%")
                return usage

            case 401, 403:
                throw APIError.unauthorized

            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Fetch Credits

    public func fetchCredits(organizationId: String, sessionKey: String) async throws -> BillingData? {
        guard let url = URL(string: "\(baseURL)/organizations/\(organizationId)/prepaid/credits") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("sessionKey=\(sessionKey)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        print("🌐 Fetching credits...")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return nil
            }

            print("📥 Credits API status: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                print("⚠️ Credits not available")
                return nil
            }

            let creditsResponse = try JSONDecoder().decode(APICreditsResponse.self, from: data)
            let billing = BillingData(
                amount: creditsResponse.amount,
                currency: creditsResponse.currency ?? "USD",
                autoReloadSettings: nil,
                lastUpdated: Date()
            )
            print("✅ Fetched credits: $\(billing.dollars)")
            return billing

        } catch {
            print("⚠️ Failed to fetch credits: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Helper Methods

    private func parseUsageResponse(_ response: APIUsageResponse) throws -> UsageData {
        let fiveHourPeriod = UsageData.UsagePeriod(
            utilization: response.five_hour.utilization,
            resetsAt: parseISO8601(response.five_hour.resets_at) ?? Date()
        )

        let sevenDayPeriod = UsageData.UsagePeriod(
            utilization: response.seven_day.utilization,
            resetsAt: parseISO8601(response.seven_day.resets_at) ?? Date()
        )

        return UsageData(
            fiveHour: fiveHourPeriod,
            sevenDay: sevenDayPeriod,
            lastUpdated: Date()
        )
    }

    private func parseISO8601(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}

// MARK: - API Response Models

private struct Organization: Codable {
    let uuid: String
    let name: String?
}

private struct APIUsageResponse: Codable {
    let five_hour: UsagePeriod
    let seven_day: UsagePeriod

    struct UsagePeriod: Codable {
        let utilization: Double
        let resets_at: String
    }
}

private struct APICreditsResponse: Codable {
    let amount: Int
    let currency: String?
    let auto_reload_settings: AutoReload?

    struct AutoReload: Codable {
        let enabled: Bool?
    }
}
