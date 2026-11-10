import Foundation

final class MockSaveIssuerProfileUseCase: SaveIssuerProfileUseCaseProtocol {
    private(set) var savedProfiles: [IssuerProfile] = []
    var errorToThrow: Error?

    func saveProfile(_ profile: IssuerProfile) throws -> IssuerProfile {
        if let errorToThrow { throw errorToThrow }
        savedProfiles.append(profile)
        return profile
    }
}
