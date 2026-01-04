import Foundation
import SweetCookieKit

/// Reads the Claude sessionKey cookie from installed browsers so the user
/// doesn’t have to paste it manually.
enum BrowserCookieService {
    static func fetchSessionKey() throws -> String {
        let client = try BrowserCookieClient()

        // Build a query for the claude.ai domain (suffix match covers subdomains).
        let query = BrowserCookieQuery(
            domains: ["claude.ai"],
            domainMatch: .suffix,
            includeExpired: false
        )

        // Iterate through available browsers/stores until we find the cookie.
        for browser in Browser.defaultImportOrder {
            let stores = client.stores(for: browser)
            for store in stores {
                let cookies = try client.cookies(matching: query, in: store)
                if let match = cookies.first(where: { $0.name == "sessionKey" }) {
                    return match.value
                }
            }
        }

        throw NSError(
            domain: "BrowserCookieService",
            code: -2,
            userInfo: [NSLocalizedDescriptionKey: "Claude sessionKey cookie not found. Please log into claude.ai in your browser."]
        )
    }
}
