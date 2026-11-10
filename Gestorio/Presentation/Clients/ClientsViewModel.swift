import Foundation

@MainActor
@Observable
final class ClientsViewModel {
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol

    private(set) var clients: [Client] = []
    var errorMessage: String?

    init(fetchClientsUseCase: FetchClientsUseCaseProtocol) {
        self.fetchClientsUseCase = fetchClientsUseCase
    }

    convenience init() {
        self.init(fetchClientsUseCase: FetchClientsUseCase())
    }

    func load() {
        do {
            clients = try fetchClientsUseCase.fetchClients()
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func client(id: UUID) -> Client? {
        clients.first { $0.id == id }
    }
}
