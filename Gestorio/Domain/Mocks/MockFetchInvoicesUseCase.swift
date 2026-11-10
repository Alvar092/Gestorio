import Foundation

final class MockFetchInvoicesUseCase: FetchInvoicesUseCaseProtocol {
    var invoicesToReturn: [Invoice] = []
    var errorToThrow: Error?

    func fetchInvoices() throws -> [Invoice] {
        if let errorToThrow { throw errorToThrow }
        return invoicesToReturn
    }
}
