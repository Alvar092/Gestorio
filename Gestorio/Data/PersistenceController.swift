import SwiftData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            ClientEntity.self,
            AppointmentEntity.self,
            InvoiceEntity.self,
            CorrectiveInvoiceEntity.self,
            HashChainPointerEntity.self,
            ExpenseEntity.self,
            IssuerProfileEntity.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
