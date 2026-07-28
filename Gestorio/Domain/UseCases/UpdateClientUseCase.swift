import Foundation

@MainActor
protocol UpdateClientUseCaseProtocol {
    func updateClient(_ client: Client) throws -> Client
}

@MainActor
final class UpdateClientUseCase: UpdateClientUseCaseProtocol {
    private let repository: ClientRepositoryProtocol

    init(repository: ClientRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ClientRepository())
    }

    func updateClient(_ client: Client) throws -> Client {
        try repository.update(client)
    }
}
