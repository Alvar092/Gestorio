import Foundation

final class MockFetchClientsUseCase: FetchClientsUseCaseProtocol {
    var clientsToReturn: [Client] = []
    var errorToThrow: Error?

    func fetchClients() throws -> [Client] {
        if let errorToThrow { throw errorToThrow }
        return clientsToReturn
    }
}
