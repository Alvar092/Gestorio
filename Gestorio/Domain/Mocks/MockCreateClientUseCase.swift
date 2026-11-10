import Foundation

final class MockCreateClientUseCase: CreateClientUseCaseProtocol {
    private(set) var createdClients: [Client] = []
    var errorToThrow: Error?

    func createClient(_ client: Client) throws -> Client {
        if let errorToThrow { throw errorToThrow }
        createdClients.append(client)
        return client
    }
}
