import Foundation
import SwiftData

@MainActor
protocol InvoiceChainRepositoryProtocol {
    func fetchLastHash() throws -> String
}

@MainActor
final class InvoiceChainRepository: InvoiceChainRepositoryProtocol {
    static let genesisHash = "0"

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchLastHash() throws -> String {
        let singletonID = HashChainPointerEntity.singletonID
        var descriptor = FetchDescriptor<HashChainPointerEntity>(
            predicate: #Predicate { $0.id == singletonID }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first?.lastHash ?? Self.genesisHash
    }
}
