import Foundation

final class MockInvoiceRepository: InvoiceRepositoryProtocol {
    var invoices: [Invoice] = []
    var errorToThrow: Error?

    func fetchAll() throws -> [Invoice] {
        if let errorToThrow { throw errorToThrow }
        return invoices
    }

    func fetch(id: UUID) throws -> Invoice? {
        if let errorToThrow { throw errorToThrow }
        return invoices.first { $0.id == id }
    }

    func create(_ invoice: Invoice) throws -> Invoice {
        if let errorToThrow { throw errorToThrow }
        invoices.append(invoice)
        return invoice
    }
}
