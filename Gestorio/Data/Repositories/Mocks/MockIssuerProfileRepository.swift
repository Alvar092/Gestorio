import Foundation

final class MockIssuerProfileRepository: IssuerProfileRepositoryProtocol {
    var profile: IssuerProfile?
    var errorToThrow: Error?

    func fetch() throws -> IssuerProfile? {
        if let errorToThrow { throw errorToThrow }
        return profile
    }

    func save(_ profile: IssuerProfile) throws -> IssuerProfile {
        if let errorToThrow { throw errorToThrow }
        self.profile = profile
        return profile
    }
}
