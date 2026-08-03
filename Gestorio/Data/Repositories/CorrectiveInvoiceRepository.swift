import Foundation
import SwiftData

@MainActor
protocol CorrectiveInvoiceRepositoryProtocol {
    func fetchAll() throws -> [CorrectiveInvoice]
    func fetch(id: UUID) throws -> CorrectiveInvoice?
    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice
}

@MainActor
final class CorrectiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchAll() throws -> [CorrectiveInvoice] {
        let descriptor = FetchDescriptor<CorrectiveInvoiceEntity>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func fetch(id: UUID) throws -> CorrectiveInvoice? {
        try entity(id: id)?.domain
    }

    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice {
        let entity = CorrectiveInvoiceEntity(correctiveInvoice: correctiveInvoice)
        modelContext.insert(entity)
        try upsertChainPointer(hash: correctiveInvoice.hash)
        try modelContext.save()
        return entity.domain
    }

    private func entity(id: UUID) throws -> CorrectiveInvoiceEntity? {
        var descriptor = FetchDescriptor<CorrectiveInvoiceEntity>(predicate: #Predicate { $0.id == id })
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

private extension CorrectiveInvoiceEntity {
    convenience init(correctiveInvoice: CorrectiveInvoice) {
        self.init(
            id: correctiveInvoice.id,
            number: correctiveInvoice.number,
            date: correctiveInvoice.date,
            clientName: correctiveInvoice.clientName,
            clientTaxID: correctiveInvoice.clientTaxID,
            concept: correctiveInvoice.concept,
            totalPrice: correctiveInvoice.totalPrice,
            originalInvoiceNumber: correctiveInvoice.originalInvoiceNumber,
            originalInvoiceHash: correctiveInvoice.originalInvoiceHash,
            previousHash: correctiveInvoice.previousHash,
            hash: correctiveInvoice.hash
        )
    }

    var domain: CorrectiveInvoice {
        CorrectiveInvoice(
            id: id,
            number: number,
            date: date,
            clientName: clientName,
            clientTaxID: clientTaxID,
            concept: concept,
            totalPrice: totalPrice,
            originalInvoiceNumber: originalInvoiceNumber,
            originalInvoiceHash: originalInvoiceHash,
            previousHash: previousHash,
            hash: hash
        )
    }
}
