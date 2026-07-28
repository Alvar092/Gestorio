import Foundation

final class MockClientRepository: ClientRepositoryProtocol {
    var clients: [Client] = []
    var errorToThrow: Error?

    func fetchAll() throws -> [Client] {
        if let errorToThrow { throw errorToThrow }
        return clients
    }

    func fetch(id: UUID) throws -> Client? {
        if let errorToThrow { throw errorToThrow }
        return clients.first { $0.id == id }
    }

    func create(_ client: Client) throws -> Client {
        if let errorToThrow { throw errorToThrow }
        clients.append(client)
        return client
    }

    func update(_ client: Client) throws -> Client {
        if let errorToThrow { throw errorToThrow }
        guard let index = clients.firstIndex(where: { $0.id == client.id }) else {
            throw RepositoryError.notFound
        }
        clients[index] = client
        return client
    }

    func delete(id: UUID) throws {
        if let errorToThrow { throw errorToThrow }
        guard let index = clients.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        clients.remove(at: index)
    }
}
