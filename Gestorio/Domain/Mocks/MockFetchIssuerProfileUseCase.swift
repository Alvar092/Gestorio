import Foundation

final class MockFetchIssuerProfileUseCase: FetchIssuerProfileUseCaseProtocol {
    var profileToReturn: IssuerProfile?
    var errorToThrow: Error?

    func fetchProfile() throws -> IssuerProfile? {
        if let errorToThrow { throw errorToThrow }
        return profileToReturn
    }
}
