import Foundation

@MainActor
protocol CreateClientUseCaseProtocol {
    func createClient(_ client: Client) throws -> Client
}

@MainActor
final class CreateClientUseCase: CreateClientUseCaseProtocol {
    private let repository: ClientRepositoryProtocol

    init(repository: ClientRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ClientRepository())
    }

    func createClient(_ client: Client) throws -> Client {
        try repository.create(client)
    }
}
