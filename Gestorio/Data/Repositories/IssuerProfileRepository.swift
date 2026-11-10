import Foundation
import SwiftData

@MainActor
protocol IssuerProfileRepositoryProtocol {
    func fetch() throws -> IssuerProfile?
    func save(_ profile: IssuerProfile) throws -> IssuerProfile
}

@MainActor
final class IssuerProfileRepository: IssuerProfileRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetch() throws -> IssuerProfile? {
        try entity().map { IssuerProfile(name: $0.name, taxID: $0.taxID) }
    }

    func save(_ profile: IssuerProfile) throws -> IssuerProfile {
        if let entity = try entity() {
            entity.name = profile.name
            entity.taxID = profile.taxID
        } else {
            modelContext.insert(IssuerProfileEntity(name: profile.name, taxID: profile.taxID))
        }
        try modelContext.save()
        return profile
    }

    private func entity() throws -> IssuerProfileEntity? {
        let singletonID = IssuerProfileEntity.singletonID
        var descriptor = FetchDescriptor<IssuerProfileEntity>(predicate: #Predicate { $0.id == singletonID })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
