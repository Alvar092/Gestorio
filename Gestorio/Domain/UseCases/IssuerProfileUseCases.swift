import Foundation

@MainActor
protocol FetchIssuerProfileUseCaseProtocol {
    func fetchProfile() throws -> IssuerProfile?
}

@MainActor
final class FetchIssuerProfileUseCase: FetchIssuerProfileUseCaseProtocol {
    private let repository: IssuerProfileRepositoryProtocol

    init(repository: IssuerProfileRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: IssuerProfileRepository())
    }

    func fetchProfile() throws -> IssuerProfile? {
        try repository.fetch()
    }
}

@MainActor
protocol SaveIssuerProfileUseCaseProtocol {
    func saveProfile(_ profile: IssuerProfile) throws -> IssuerProfile
}

@MainActor
final class SaveIssuerProfileUseCase: SaveIssuerProfileUseCaseProtocol {
    private let repository: IssuerProfileRepositoryProtocol

    init(repository: IssuerProfileRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: IssuerProfileRepository())
    }

    func saveProfile(_ profile: IssuerProfile) throws -> IssuerProfile {
        try repository.save(profile)
    }
}
