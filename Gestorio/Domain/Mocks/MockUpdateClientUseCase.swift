import Foundation

final class MockUpdateClientUseCase: UpdateClientUseCaseProtocol {
    private(set) var updatedClients: [Client] = []
    var errorToThrow: Error?

    func updateClient(_ client: Client) throws -> Client {
        if let errorToThrow { throw errorToThrow }
        updatedClients.append(client)
        return client
    }
}
