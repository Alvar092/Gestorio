import Foundation
import SwiftData

@MainActor
protocol ClientRepositoryProtocol {
    func fetchAll() throws -> [Client]
    func fetch(id: UUID) throws -> Client?
    func create(_ client: Client) throws -> Client
    func update(_ client: Client) throws -> Client
    func delete(id: UUID) throws
}

@MainActor
final class ClientRepository: ClientRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchAll() throws -> [Client] {
        let descriptor = FetchDescriptor<ClientEntity>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func fetch(id: UUID) throws -> Client? {
        try entity(id: id)?.domain
    }

    func create(_ client: Client) throws -> Client {
        let entity = ClientEntity(client: client)
        modelContext.insert(entity)
        try modelContext.save()
        return entity.domain
    }

    func update(_ client: Client) throws -> Client {
        guard let entity = try entity(id: client.id) else {
            throw RepositoryError.notFound
        }
        entity.update(from: client)
        try modelContext.save()
        return entity.domain
    }

    func delete(id: UUID) throws {
        guard let entity = try entity(id: id) else {
            throw RepositoryError.notFound
        }
        modelContext.delete(entity)
        try modelContext.save()
    }

    private func entity(id: UUID) throws -> ClientEntity? {
        var descriptor = FetchDescriptor<ClientEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}

private extension ClientEntity {
    convenience init(client: Client) {
        self.init(
            id: client.id,
            name: client.name,
            taxID: client.taxID,
            street: client.billingAddress.street,
            postalCode: client.billingAddress.postalCode,
            city: client.billingAddress.city,
            province: client.billingAddress.province,
            email: client.email,
            phone: client.phone,
            notes: client.notes
        )
    }

    func update(from client: Client) {
        name = client.name
        taxID = client.taxID
        street = client.billingAddress.street
        postalCode = client.billingAddress.postalCode
        city = client.billingAddress.city
        province = client.billingAddress.province
        email = client.email
        phone = client.phone
        notes = client.notes
    }

    var domain: Client {
        Client(
            id: id,
            name: name,
            taxID: taxID,
            billingAddress: BillingAddress(street: street, postalCode: postalCode, city: city, province: province),
            email: email,
            phone: phone,
            notes: notes
        )
    }
}
