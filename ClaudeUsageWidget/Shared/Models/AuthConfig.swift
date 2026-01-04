import Foundation

public struct AuthConfig: Codable {
    public let organizationId: String
    public let lastValidated: Date

    public init(organizationId: String, lastValidated: Date = Date()) {
        self.organizationId = organizationId
        self.lastValidated = lastValidated
    }
}
