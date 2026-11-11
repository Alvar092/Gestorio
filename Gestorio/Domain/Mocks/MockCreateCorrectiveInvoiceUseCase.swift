import Foundation

final class MockCreateCorrectiveInvoiceUseCase: CreateCorrectiveInvoiceUseCaseProtocol {
    private(set) var createdCorrectiveInvoices: [CorrectiveInvoice] = []
    var errorToThrow: Error?

    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice {
        if let errorToThrow { throw errorToThrow }
        createdCorrectiveInvoices.append(correctiveInvoice)
        return correctiveInvoice
    }
}
