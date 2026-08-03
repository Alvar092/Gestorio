import Foundation

final class MockCorrectiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol {
    var correctiveInvoices: [CorrectiveInvoice] = []
    var errorToThrow: Error?

    func fetchAll() throws -> [CorrectiveInvoice] {
        if let errorToThrow { throw errorToThrow }
        return correctiveInvoices
    }

    func fetch(id: UUID) throws -> CorrectiveInvoice? {
        if let errorToThrow { throw errorToThrow }
        return correctiveInvoices.first { $0.id == id }
    }

    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice {
        if let errorToThrow { throw errorToThrow }
        correctiveInvoices.append(correctiveInvoice)
        return correctiveInvoice
    }
}
