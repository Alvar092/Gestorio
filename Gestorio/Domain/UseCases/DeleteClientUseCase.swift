import Foundation

@MainActor
protocol DeleteClientUseCaseProtocol {
    func deleteClient(id: UUID) throws
}

@MainActor
final class DeleteClientUseCase: DeleteClientUseCaseProtocol {
    private let repository: ClientRepositoryProtocol

    init(repository: ClientRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ClientRepository())
    }

    func deleteClient(id: UUID) throws {
        try repository.delete(id: id)
    }
}
