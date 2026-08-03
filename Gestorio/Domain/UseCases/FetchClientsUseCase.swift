import Foundation

@MainActor
protocol FetchClientsUseCaseProtocol {
    func fetchClients() throws -> [Client]
}

@MainActor
final class FetchClientsUseCase: FetchClientsUseCaseProtocol {
    private let repository: ClientRepositoryProtocol

    init(repository: ClientRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ClientRepository())
    }

    func fetchClients() throws -> [Client] {
        try repository.fetchAll()
    }
}
