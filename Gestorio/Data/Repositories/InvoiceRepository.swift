import Foundation
import SwiftData

@MainActor
protocol InvoiceRepositoryProtocol {
    func fetchAll() throws -> [Invoice]
    func fetch(id: UUID) throws -> Invoice?
    func create(_ invoice: Invoice) throws -> Invoice
}

@MainActor
final class InvoiceRepository: InvoiceRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchAll() throws -> [Invoice] {
        let descriptor = FetchDescriptor<InvoiceEntity>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func fetch(id: UUID) throws -> Invoice? {
        try entity(id: id)?.domain
    }

    func create(_ invoice: Invoice) throws -> Invoice {
        let entity = InvoiceEntity(invoice: invoice)
        modelContext.insert(entity)
        try upsertChainPointer(hash: invoice.hash)
        try modelContext.save()
        return entity.domain
    }

    private func entity(id: UUID) throws -> InvoiceEntity? {
        var descriptor = FetchDescriptor<InvoiceEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func upsertChainPointer(hash: String) throws {
        let singletonID = HashChainPointerEntity.singletonID
        var descriptor = FetchDescriptor<HashChainPointerEntity>(
            predicate: #Predicate { $0.id == singletonID }
        )
        descriptor.fetchLimit = 1
        if let pointer = try modelContext.fetch(descriptor).first {
            pointer.lastHash = hash
        } else {
            modelContext.insert(HashChainPointerEntity(lastHash: hash))
        }
    }
}

private extension InvoiceEntity {
    convenience init(invoice: Invoice) {
        self.init(
            id: invoice.id,
            number: invoice.number,
            date: invoice.date,
            clientName: invoice.clientName,
            clientTaxID: invoice.clientTaxID,
            concept: invoice.concept,
            totalPrice: invoice.totalPrice,
            previousHash: invoice.previousHash,
            hash: invoice.hash
        )
    }

    var domain: Invoice {
        Invoice(
            id: id,
            number: number,
            date: date,
            clientName: clientName,
            clientTaxID: clientTaxID,
            concept: concept,
            totalPrice: totalPrice,
            previousHash: previousHash,
            hash: hash
        )
    }
}
