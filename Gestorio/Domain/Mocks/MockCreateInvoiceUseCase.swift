import Foundation

final class MockCreateInvoiceUseCase: CreateInvoiceUseCaseProtocol {
    private(set) var createdInvoices: [Invoice] = []
    var errorToThrow: Error?

    func create(_ invoice: Invoice) throws -> Invoice {
        if let errorToThrow { throw errorToThrow }
        createdInvoices.append(invoice)
        return invoice
    }
}
