import Foundation

final class MockFetchCorrectiveInvoicesUseCase: FetchCorrectiveInvoicesUseCaseProtocol {
    var correctiveInvoicesToReturn: [CorrectiveInvoice] = []
    var errorToThrow: Error?

    func fetchCorrectiveInvoices() throws -> [CorrectiveInvoice] {
        if let errorToThrow { throw errorToThrow }
        return correctiveInvoicesToReturn
    }
}
